# DEV_DOC — Developer Documentation

This document explains how to set up, build, and manage the Inception project from a developer's perspective.

---

## Prerequisites

The following must be available on your host machine (virtual machine in my case) before starting:

- Linux OS (this project uses Alpine 3.22.3 as the base for all containers)
- Docker Engine (>= 20.x) and the Docker Compose plugin (`docker compose`)
- `make`
- `git`
- A user with permission to run Docker, or root access

---

## Repository structure

```
.
├── DEV_DOC.md
├── Makefile
├── README.md
├── USER_DOC.md
├── .gitignore  
└── srcs
    ├── docker-compose.yml
    ├── .env                         # all environment variables and credentials (git-ignored)
    ├── .gitignore                   # ignores .env
    └── requirements
        ├── mariadb
        │   ├── Dockerfile
        |   ├── .dockerignore
        │   ├── conf
        │   │   └── mariadb.cnf     # [mysqld] config: datadir, socket, bind-address, port
        │   └── tools
        │   |   └── mariadb-script.sh # init db, create user, start mariadbd
        ├── nginx
        │   ├── Dockerfile
        │   ├── conf
        │   |   ├── nginx.conf      # TLSv1.3, fastcgi_pass to wordpress:9000
        |   ├── .dockerignore
        └── wordpress
            ├── Dockerfile
            ├── .dockerignore
            ├── conf
            │   └── www.conf        # php-fpm pool: listen 9000, www-data user
            └── tools
                └── wordpress-script.sh  # wait for db, WP-CLI install, exec php-fpm83

```

---

## Setting up the environment from scratch

### 1. Clone the repository

```bash
git clone <repo_url> inception
cd inception
```

### 2. Create srcs/.env

This file is git-ignored and must be created manually. The variable names must match exactly what the scripts expect:

```env
DOMAIN_NAME=trpham.42.fr

MYSQL_ROOT_PASSWORD=4242

WORDPRESS_TITLE=inception_wp
WORDPRESS_DATABASE_NAME=wordpress_db
WORDPRESS_DATABASE_PASSWORD=4242

WORDPRESS_DATABASE_USER=trpham
WORDPRESS_DATABASE_USER_PASSWORD=4242

WORDPRESS_ADMIN=athena
WORDPRESS_ADMIN_PASSWORD=4242
WORDPRESS_ADMIN_EMAIL=hatrangc2@gmail.com

WORDPRESS_USER=editor
WORDPRESS_USER_PASSWORD=4242
WORDPRESS_USER_EMAIL=trpham@student.hive.fi
```

### 4. Configure /etc/hosts

```bash
echo "127.0.0.1   trpham.42.fr" | sudo tee -a /etc/hosts
```

---

## Building and launching the project

All operations go through the `Makefile` at the project root.

```bash
make        # create mariadb and wordpress data folder, docker compose up build and up
make down   # docker compose down
make clean  # docker compose down 
make fclean # docker compose clean, remove the data directories, @docker system prune -f --volumes  
make re     # make fclean && make
```

To run manually without the Makefile:
```bash
cd srcs
docker compose up --build -d
```

---

## How each service starts

### MariaDB (`mariadb-script.sh`)

The entrypoint script runs as `sh` (exec form via `ENTRYPOINT`):

1. Creates `/var/lib/mysql`, `/run/mysqld`, `/var/log/mysql` and sets ownership to `mysql:mysql`.
2. If `/var/lib/mysql/mysql` does not exist, runs `mariadb-install-db` to initialise a fresh data directory.
3. Writes a SQL init file to `${DATADIR}/init.sql` containing: set root password, create the WordPress database, create the WordPress user, grant privileges.
4. Starts `mariadbd` in the foreground with `exec mariadbd --defaults-file=... --init-file=...`. The `--init-file` is consumed once on this first start and is ignored on subsequent starts since the database directory already exists.

The compose healthcheck pings MariaDB with `mariadb-admin ping` every 10s (up to 10 retries) before WordPress is allowed to start.

### WordPress (`wordpress-script.sh`)

The entrypoint script runs as `sh`:

1. Sets `memory_limit = 512M` in `php.ini`.
2. Downloads WP-CLI (`wp-cli.phar`) from GitHub and installs it as `/usr/local/bin/wp`.
3. Waits for MariaDB to accept connections using `mariadb-admin ping --wait=300`.
4. If `wp-settings.php` is absent, downloads WordPress core with `wp core download --allow-root`.
5. If `wp-config.php` is absent, creates it with `wp config create` (pointing `--dbhost=mariadb`) and installs WordPress with `wp core install`, then creates the second user with `wp user create`.
6. Sets ownership of `/var/www/html` to `www-data:www-data`.
7. Starts PHP-FPM in the foreground with `exec php-fpm83 -F`.

This script is idempotent — on subsequent container starts, steps 4 and 5 are skipped because the files already exist on the shared volume.

### NGINX (no entrypoint script)

The TLS certificate and key are generated at **image build time** in the `Dockerfile`:
```dockerfile
RUN openssl req -x509 -nodes \
    -out /etc/nginx/certs/public_certificate.crt \
    -keyout /etc/nginx/certs/private.key \
    -subj "/C=FI/ST=Uusimaa/L=Helsinki/O=42/OU=Hive/CN=trpham.42.fr"
```

NGINX starts directly via `CMD ["nginx", "-c", "/etc/nginx/nginx.conf", "-g", "daemon off;"]`. FastCGI requests are forwarded to `wordpress:9000`. NGINX also mounts the WordPress volume at `/var/www/html` to serve static assets without hitting php-fpm.

---

## Managing containers and volumes

### Check status

```bash
docker ps
docker compose -f srcs/docker-compose.yml ps
```

### View logs

```bash
docker logs mariadb
docker logs wordpress
docker logs nginx

# Follow in real time:
docker logs -f wordpress
```

### Execute a command inside a container

```bash
docker exec -it mariadb sh
docker exec -it mariadb mariadb -u root -p
docker exec -it wordpress sh
docker exec -it nginx sh
```

### Restart a single service

```bash
docker compose -f srcs/docker-compose.yml restart nginx
```

### Rebuild a single service

```bash
docker compose -f srcs/docker-compose.yml up --build -d wordpress
```

---

## Data persistence

| Data | Volume name | Host path |
|---|---|---|
| MariaDB database files | `mariadb` | `/home/trpham/data/mariadb` |
| WordPress site files | `wordpress` | `/home/trpham/data/wordpress` |

Both volumes use `driver: local` with `type: none` and `o: bind`, which makes them backed by specific host directories. Data survives `docker compose down` but is removed if you delete the host directories or run `make fclean`.

The `wordpress` volume is shared between the `wordpress` and `nginx` containers (both mount it at `/var/www/html`).

