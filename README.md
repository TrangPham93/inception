*This project has been created as part of the 42 curriculum by trpham.*

# Inception

## Description

Inception is a system administration project from the 42 school curriculum. The goal is to build a small but complete web infrastructure using Docker and Docker Compose, entirely inside a virtual machine. Rather than relying on pre-built images from Docker Hub, you write your own `Dockerfile` for each service and orchestrate them together.

The stack consists of three core services running in isolated containers:

- **NGINX** — the sole entry point to the infrastructure, handling HTTPS traffic on port 443 with TLSv1.2/TLSv1.3
- **WordPress + php-fpm** — the application layer, running without NGINX
- **MariaDB** — the database backend

Two persistent Docker volumes store the WordPress database and website files. All containers communicate over a dedicated Docker network.

### Design choices

#### Virtual Machines vs Docker

A Virtual Machine emulates an entire operating system on top of hardware via a hypervisor, giving full isolation but at the cost of significant overhead (RAM, disk, boot time). Docker containers share the host OS kernel and isolate only the process environment, making them far lighter and faster to start. For this project, Docker lets us run multiple services on a single VM with minimal resource usage and reproducible builds.

#### Secrets vs Environment Variables

Environment variables (via `.env`) are convenient for non-sensitive configuration like domain names and usernames. However, they can be leaked through process inspection or logs. Docker Secrets store sensitive values (passwords, keys) as files mounted into containers at runtime, never exposed as environment variables. This project uses a `.env` file for general config and a `secrets/` directory for credentials, which must be git-ignored.

#### Docker Network vs Host Network

With `network: host`, a container shares the host's network namespace directly — no isolation, no DNS between containers, and a security risk. A custom Docker bridge network (used here) gives each container its own IP, allows DNS resolution by service name, and keeps the infrastructure isolated from the host except for explicitly published ports.

#### Docker Volumes vs Bind Mounts

Bind mounts link a host directory directly into the container — simple but dependent on host paths and permissions. Docker volumes are managed by Docker, stored under `/var/lib/docker/volumes/`, portable, and easier to back up. This project uses named volumes for both the database and WordPress files to ensure data persists across container restarts and rebuilds.

---

## Instructions

### Prerequisites

- A virtual machine running Linux (Debian or Alpine recommended)
- Docker and Docker Compose installed
- `make` available
- Your login set as the domain: `<login>.42.fr` pointing to `127.0.0.1` in `/etc/hosts`

### Configuration

1. Clone the repository into your VM.
2. Create the `secrets/` directory at the root and populate the required files:
   ```
   secrets/credentials.txt       # WordPress admin credentials
   secrets/db_password.txt       # MariaDB user password
   secrets/db_root_password.txt  # MariaDB root password
   ```
3. Edit `srcs/.env` and set your values:
   ```env
   DOMAIN_NAME=<login>.42.fr
   MYSQL_USER=<your_db_user>
   # etc.
   ```
4. Add your domain to `/etc/hosts`:
   ```
   127.0.0.1   <login>.42.fr
   ```

### Build and run

```bash
make        # builds images and starts all containers
make down   # stops and removes containers
make clean  # removes containers, volumes, and images
make re     # full rebuild
```

Once running, visit `https://<login>.42.fr` in your browser.

---

## Resources

### Documentation

- [Docker official docs](https://docs.docker.com/)
- [Docker Compose reference](https://docs.docker.com/compose/)
- [NGINX docs](https://nginx.org/en/docs/)
- [WordPress CLI](https://wp-cli.org/)
- [MariaDB docs](https://mariadb.com/kb/en/documentation/)
- [Best practices for writing Dockerfiles](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
- [PID 1 and Docker](https://blog.phusion.nl/2015/01/20/docker-and-the-pid-1-zombie-reaping-problem/)
- [Docker Secrets](https://docs.docker.com/engine/swarm/secrets/)
- [TLS configuration in NGINX](https://nginx.org/en/docs/http/configuring_https_servers.html)

### How AI was used

AI assistance (Claude) was used in the following parts of this project:

- **Documentation**: generating the initial structure and content of `README.md`, `USER_DOC.md`, and `DEV_DOC.md`, then reviewed and adapted to match the actual implementation.
- **Dockerfile troubleshooting**: asking for explanations of PID 1 behavior, daemon modes, and `CMD` vs `ENTRYPOINT` semantics.
- **Configuration snippets**: getting starting points for NGINX TLS config and WordPress php-fpm pool settings, which were then tested, understood, and modified.

All AI-generated content was reviewed, tested, and validated before inclusion. Nothing was copy-pasted without understanding.
