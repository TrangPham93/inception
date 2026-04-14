# USER_DOC — User Documentation

This document explains how to use and operate the Inception infrastructure as an end user or administrator.

---

## Services provided

The project runs a fully functional WordPress website accessible over HTTPS. Three services work together inside Docker containers:

| Service | Role | Port |
|---|---|---|
| **NGINX** | Web server — the only door into the infrastructure. Handles all HTTPS connections and forwards PHP requests to WordPress. | 443 (public) |
| **WordPress + php-fpm** | The website application. Manages content, users, and serves pages. | 9000 (internal only) |
| **MariaDB** | The database. Stores all WordPress content, settings, and user accounts. | 3306 (internal only) |

Only NGINX is reachable from outside. WordPress and MariaDB are only accessible to each other inside the private Docker network.

---

## Starting and stopping the project

All commands are run from the **root of the project directory** on your virtual machine.

### Start the project

```bash
make
```

On the first run this builds all Docker images and may take a few minutes. WordPress is also installed automatically during this first startup. All the images, containers and volumes should be ready when the process is done.

### Stop the project (data preserved)

```bash
make down
```

Stops all containers. Your website content and database are fully preserved and will be there when you start again.

OR

```bash
make clean
```

> **Warning:** this is similar to ```bash make down ```

### Full reset (removes all data)

```bash
make fclean
```

> **Warning:** this will run ```bash make clean ``` first, then forcefully removes your data directories saved on your host machine and all unused Docker resources. This is a full reset. 
---

## Accessing the website

Once the project is running:

**Website:**
```
https://trpham.42.fr
```

Your browser will show a warning about the certificate because the project uses a self-signed TLS certificate. This is expected. Click **Advanced** (or **Details**) and then **Proceed** to reach the site.

**WordPress admin panel:**
```
https://trpham.42.fr/wp-admin
```

Log in with the administrator credentials defined in `srcs/.env`.

---

## Credentials

All credentials are stored in `srcs/.env`. This file is never committed to Git.

| What | Variable in .env |
|---|---|
| Database root password | `MYSQL_ROOT_PASSWORD` |
| Database port | `DB_PORT` |
| WordPress title | `WORDPRESS_TITLE` |
| Database name | `WORDPRESS_DATABASE_NAME` |
| Database password | `WORDPRESS_DATABASE_PASSWORD` |
| Database user | `WORDPRESS_DATABASE_USER` |
| Database user password | `WORDPRESS_DATABASE_USER_PASSWORD` |
| WordPress admin username | `WORDPRESS_ADMIN` |
| WordPress admin password | `WORDPRESS_ADMIN_PASSWORD` |
| WordPress admin email | `WORDPRESS_ADMIN_EMAIL` |
| WordPress regular user | `WORDPRESS_USER` |
| WordPress regular user password | `WORDPRESS_USER_PASSWORD` |
| WordPress regular user email | `WORDPRESS_USER_EMAIL` |

> Keep `srcs/.env` private. Never push it to any remote repository.

---

## Checking that services are running correctly

### Quick status check

```bash
docker ps
```

You should see three containers — `mariadb`, `wordpress`, and `nginx` — all with status `Up`. On first startup, `wordpress` may show `starting` for a minute while it downloads and installs WordPress.

### Check if the website responds

```bash
curl -k https://trpham.42.fr
```

If you get HTML back, the site is up. The `-k` flag skips certificate verification for self-signed certs.

### View logs for a specific service

```bash
docker logs nginx
docker logs wordpress
docker logs mariadb
```

If a container is crashing or behaving unexpectedly, its logs will show the reason.

### Check a container's health status

```bash
docker inspect --format='{{.State.Health.Status}}' mariadb
docker inspect --format='{{.State.Status}}' nginx
```

Expected output: `healthy` for mariadb, `running` for nginx and wordpress.

---

## Managing the WordPress site

Once logged into `https://trpham.42.fr/wp-admin` as the administrator, you can:

- Create and publish posts and pages under **Posts** and **Pages**
- Install themes under **Appearance → Themes**
- Install plugins under **Plugins → Add New**
- Manage users under **Users**
- Configure site settings under **Settings**

### Users

The site is set up with two users by default:

| Role | Variable |
|---|---|
| Administrator | `WORDPRESS_ADMIN` — full admin panel access |
| Author | `WORDPRESS_USER` — can write and publish posts |

To add more users: go to **Users → Add New** in the admin panel.

---

## Where data is stored

WordPress files and the database are stored on the host machine at:

```
/home/trpham/data/wordpress/   ← WordPress core files, themes, plugins, uploads
/home/trpham/data/mariadb/     ← MariaDB database files
```

These directories persist across `make down` and `make` restarts. They are only removed by `make fclean`.

---

## Troubleshooting

| Symptom | What to try |
|---|---|
| Browser says "site can't be reached" | Run `docker ps` — are all three containers `Up`? Check that `/etc/hosts` has `127.0.0.1 trpham.42.fr` |
| Browser shows a certificate warning | Normal — accept it and continue to the site |
| "Error establishing database connection" on the WordPress page | MariaDB may still be initialising; wait 30–60 seconds and refresh |
| Admin login not working | Double-check `WORDPRESS_ADMIN` and `WORDPRESS_ADMIN_PASSWORD` in `srcs/.env` |
| Site loads but looks broken (no styles) | Check `docker logs nginx` for errors; make sure the WordPress volume is mounted correctly |
| Containers keep restarting | Run `docker logs <container_name>` to see the error; likely a misconfigured `.env` variable |