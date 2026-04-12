# DEV_DOC — Developer Documentation

This document explains how to set up, build, and manage the Inception project from a developer's perspective.

---

## Prerequisites

Before starting, make sure the following are available on your virtual machine:

- Linux OS (Debian or Alpine recommended, penultimate stable version)
- Docker Engine (>= 20.x)
- Docker Compose (>= 2.x, or the `docker compose` plugin)
- `make`
- `git`
- A user with permission to run Docker (or root access)

To install Docker on Debian:

```bash
sudo apt update && sudo apt install -y docker.io docker-compose-plugin
sudo usermod -aG docker $USER
newgrp docker
```

---

## Repository structure

```
.
├── Makefile
├── secrets/
│   ├── credentials.txt        # WordPress admin user + password
│   ├── db_password.txt        # MariaDB regular user password
│   └── db_root_password.txt   # MariaDB root password
└── srcs/
    ├── .env                   # Non-sensitive environment variables
    ├── docker-compose.yml
    └── requirements/
        ├── nginx/
        │   ├── Dockerfile
        │   ├── conf/          # nginx.conf or site config
        │   └── tools/         # entrypoint scripts
        ├── wordpress/
        │   ├── Dockerfile
        │   ├── conf/          # php-fpm pool config
        │   └── tools/         # wp-cli setup script
        ├── mariadb/
        │   ├── Dockerfile
        │   ├── conf/          # my.cnf or custom config
        │   └── tools/         # db init script
        └── bonus/             # bonus services (if applicable)
```

---

## Setting up the environment from scratch

### 1. Clone the repository

```bash
git clone <your_repo_url>
cd inception
```

### 2. Create the secrets directory

The `secrets/` directory must **never** be committed to git. Create it manually:

```bash
mkdir -p secrets
echo "your_db_user_password"   > secrets/db_password.txt
echo "your_db_root_password"   > secrets/db_root_password.txt
# credentials.txt format: user:password or however your setup script reads it
echo "wpuser:your_wp_password" > secrets/credentials.txt
```

Make sure `secrets/` is listed in `.gitignore`.

### 3. Configure the .env file

Edit `srcs/.env`:

```env
DOMAIN_NAME=<login>.42.fr

# MariaDB
MYSQL_DATABASE=wordpress
MYSQL_USER=wpuser

# WordPress
WP_TITLE=My Site
WP_ADMIN_USER=myadmin        # must NOT contain 'admin' or 'administrator'
WP_ADMIN_EMAIL=admin@example.com
WP_USER=regularuser
WP_USER_EMAIL=user@example.com
```

Passwords should be read from the secrets files — never hardcoded in `.env` or `Dockerfiles`.

### 4. Configure the local domain

Add the following line to `/etc/hosts` on your VM:

```
127.0.0.1   <login>.42.fr
```

### 5. Create data directories for volumes

Volumes are mounted to `/home/<login>/data` on the host:

```bash
mkdir -p /home/$USER/data/wordpress
mkdir -p /home/$USER/data/mariadb
```

---

## Building and launching the project

The `Makefile` at the root handles all operations. It calls `docker compose` with the `srcs/docker-compose.yml` file.

```bash
make          # Build all images and start containers in detached mode
make down     # Stop and remove containers (volumes preserved)
make clean    # Stop containers and remove volumes + images
make re       # Full clean rebuild (equivalent to clean + make)
make logs     # Tail logs from all containers (if defined in Makefile)
```

To build and start manually without the Makefile:

```bash
cd srcs
docker compose up --build -d
```

---

## Managing containers and volumes

### Check running containers

```bash
docker ps
docker compose -f srcs/docker-compose.yml ps
```

### View logs

```bash
docker logs nginx
docker logs wordpress
docker logs mariadb

# Or follow in real time:
docker logs -f wordpress
```

### Execute a command inside a container

```bash
docker exec -it wordpress bash
docker exec -it mariadb mariadb -u root -p
```

### Restart a specific container

```bash
docker compose -f srcs/docker-compose.yml restart nginx
```

### Rebuild a single service

```bash
docker compose -f srcs/docker-compose.yml up --build -d nginx
```

### Inspect the Docker network

```bash
docker network ls
docker network inspect srcs_inception   # name may vary based on compose project name
```

### List and inspect volumes

```bash
docker volume ls
docker volume inspect srcs_db_volume
docker volume inspect srcs_wp_volume
```

---

## Data persistence

| Data | Volume name | Host path |
|---|---|---|
| MariaDB database files | `db_volume` (or similar) | `/home/<login>/data/mariadb` |
| WordPress website files | `wp_volume` (or similar) | `/home/<login>/data/wordpress` |

Volume names are defined in `srcs/docker-compose.yml` under the `volumes:` key. Data persists across `docker compose down` but is removed by `docker compose down -v` or `make clean`.

---

## Key implementation notes

- **No pre-built images**: every service is built from a custom `Dockerfile`. Base images must be the penultimate stable version of Alpine or Debian. The `latest` tag is forbidden.
- **No passwords in Dockerfiles**: credentials are injected at runtime via Docker Secrets or environment variables sourced from `.env` and the `secrets/` files.
- **PID 1**: containers run their main process as PID 1 using the proper `CMD` or `ENTRYPOINT` form (exec form, not shell form). No `tail -f`, `sleep infinity`, or `while true` hacks.
- **Restart policy**: all services use `restart: unless-stopped` (or `always`) in `docker-compose.yml` to recover from crashes.
- **Single entrypoint**: NGINX is the only container exposed to the outside, on port 443 with TLS. WordPress and MariaDB are only reachable from within the Docker network.
- **No `network: host` or `--link`**: a named bridge network is defined in `docker-compose.yml` and assigned to all services.

---

## Common issues

| Problem | Likely cause | Fix |
|---|---|---|
| `https://<login>.42.fr` unreachable | `/etc/hosts` not configured | Add `127.0.0.1 <login>.42.fr` |
| MariaDB container crashes on start | Init script error or bad password | Check `docker logs mariadb`, verify secrets files |
| WordPress shows DB connection error | MariaDB not ready yet | WordPress entrypoint should retry; check startup order and `depends_on` |
| TLS certificate error in browser | Self-signed cert not trusted | Accept the browser warning (expected for self-signed certs) |
| Volume data not persisting | Wrong host path or volume not mounted | Check `docker-compose.yml` volumes section and host directory permissions |
