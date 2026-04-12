*This project has been created as part of the 42 curriculum by trpham.*

# Inception

## Description

Inception is a system administration project from the 42 school curriculum. The goal is to build a small but complete web infrastructure using Docker and Docker Compose, entirely inside a virtual machine. Rather than relying on pre-built images from Docker Hub, each service has its own custom `Dockerfile`, all built on **Alpine 3.22.3**.

The stack consists of three services running in isolated containers:

- **NGINX** — the sole entry point, handling HTTPS on port 443 with TLSv1.3. Generates its own self-signed TLS certificate at build time using `openssl`. Routes PHP requests to the WordPress container via FastCGI on port 9000.
- **WordPress + php-fpm 8.3** — the application layer, running without NGINX. Set up using WP-CLI, downloaded at container startup. Serves PHP through `php-fpm83` on port 9000.
- **MariaDB** — the database backend on port 3306. Initialised with a shell script that creates the database, user, and root password via a SQL init file on first run.

Two named Docker volumes bind-mount to `/home/trpham/data/` on the host, ensuring data persists across restarts. All three containers communicate over a custom bridge network named `docker-network`. NGINX and WordPress share the WordPress volume so NGINX can serve static files directly.

All credentials and configuration are managed through a single `srcs/.env` file, which must be git-ignored.

### Design choices

#### Virtual Machines vs Docker

A Virtual Machine emulates an entire operating system on top of hardware via a hypervisor, giving full isolation but at the cost of significant overhead (RAM, disk, boot time). Docker containers share the host OS kernel and isolate only the process environment, making them far lighter and faster to start. For this project, Docker lets us run multiple services on a single VM with minimal resource usage and fully reproducible builds described as code.

#### Secrets vs Environment Variables

Environment variables (via `.env`) are convenient for configuration and are what this project uses — the `.env` file is passed to services via `env_file` in `docker-compose.yml` and must be listed in `.gitignore` since it contains passwords. The more secure alternative is Docker Secrets, which mounts sensitive values as files inside the container at runtime, never exposing them as environment variables that could leak through process inspection or logs. For a production system, Docker Secrets would be strongly preferred.

#### Docker Network vs Host Network

With `network: host`, a container shares the host's network namespace directly — there is no isolation between containers, no inter-container DNS, and a broader attack surface. This project uses a custom bridge network (`docker-network`), which gives each container its own IP, enables DNS resolution by service name (e.g. `mariadb`, `wordpress`), and isolates the infrastructure from the host except for the single published port 443.

#### Docker Volumes vs Bind Mounts

This project uses named volumes configured with `driver: local` and `driver_opts` to bind-mount specific host directories (`/home/trpham/data/mariadb` and `/home/trpham/data/wordpress`). This combines the explicitness of bind mounts with the management benefits of named volumes — they appear in `docker volume ls`, can be referenced by name across services, and survive `docker compose down`. A pure bind mount is simpler but not managed by Docker. A pure named volume without `driver_opts` lets Docker manage storage automatically, which is more portable but less transparent about where data lives on the host.

---

## Instructions

### Prerequisites

- A virtual machine running Linux
- Docker Engine and Docker Compose plugin installed
- `make` available
- The domain `trpham.42.fr` pointing to `127.0.0.1` in `/etc/hosts`

### Configuration

1. Clone the repository into your VM.

2. Create the host data directories:
   ```bash
   mkdir -p /home/trpham/data/mariadb
   mkdir -p /home/trpham/data/wordpress
   ```

3. Create `srcs/.env` with the following variables (this file must stay out of git):
   ```env
   DOMAIN_NAME=trpham.42.fr
   WORDPRESS_TITLE=My Inception Site

   MYSQL_ROOT_PASSWORD=yourRootPassword

   WORDPRESS_DATABASE_NAME=wordpress
   WORDPRESS_DATABASE_USER=yourDbUser
   WORDPRESS_DATABASE_USER_PASSWORD=yourDbPassword

   WORDPRESS_ADMIN=yourAdminUsername
   WORDPRESS_ADMIN_PASSWORD=yourAdminPassword
   WORDPRESS_ADMIN_EMAIL=admin@trpham.42.fr

   WORDPRESS_USER=yourUsername
   WORDPRESS_USER_PASSWORD=yourUserPassword
   WORDPRESS_USER_EMAIL=user@trpham.42.fr
   ```
   > `WORDPRESS_ADMIN` must **not** contain `admin` or `administrator`.

4. Add the domain to `/etc/hosts` on your VM:
   ```
   127.0.0.1   trpham.42.fr
   ```

### Build and run

```bash
make        # builds all images and starts containers in detached mode
make down   # stops and removes containers (data preserved)
make clean  # full teardown: containers, volumes, and images
make re     # clean rebuild
```

Once running, visit `https://trpham.42.fr` in your browser and accept the self-signed certificate warning.

---

## Resources

### Documentation

- [Docker official docs](https://docs.docker.com/)
- [Docker Compose reference](https://docs.docker.com/compose/)
- [NGINX docs](https://nginx.org/en/docs/)
- [TLS configuration in NGINX](https://nginx.org/en/docs/http/configuring_https_servers.html)
- [openssl req reference](https://www.openssl.org/docs/man1.1.1/man1/req.html)
- [WP-CLI docs](https://wp-cli.org/)
- [MariaDB docs](https://mariadb.com/kb/en/documentation/)
- [php-fpm configuration](https://www.php.net/manual/en/install.fpm.configuration.php)
- [Best practices for writing Dockerfiles](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
- [PID 1 and Docker](https://blog.phusion.nl/2015/01/20/docker-and-the-pid-1-zombie-reaping-problem/)

### How AI was used

AI assistance (Claude) was used in the following parts of this project:

- **Documentation**: generating the initial structure and full content of `README.md`, `USER_DOC.md`, and `DEV_DOC.md`, then reviewed and adjusted to match the actual implementation.
- **Dockerfile research**: asking for explanations of `CMD` vs `ENTRYPOINT` exec form, PID 1 behaviour, and Alpine package names for php83 and MariaDB.
- **Script logic**: discussing the MariaDB init-file approach and the WP-CLI flow for idempotent WordPress setup.

All AI-generated content was reviewed, tested, and validated before inclusion. Nothing was copy-pasted without understanding.