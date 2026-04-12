USER_DOC — User Documentation
This document explains how to use the Inception infrastructure as an end user or administrator. No Docker knowledge is required.
---
What services does this stack provide?
The Inception project runs a fully functional WordPress website accessible over HTTPS. It is made up of three services working together:
Service	Role
NGINX	Web server — handles all incoming HTTPS connections and forwards requests to WordPress
WordPress	The website application — where content is managed and served
MariaDB	The database — stores all WordPress content, users, and settings
All three run as Docker containers on the same machine and communicate over a private internal network. From the outside, only the NGINX container is accessible (port 443).
---
Starting and stopping the project
All commands are run from the root of the project directory on the host machine (your virtual machine).
Start the project
```bash
make
```
This builds the Docker images (if not already built) and starts all containers. It may take a minute or two the first time.
Stop the project
```bash
make down
```
This stops all containers. Your data (website content and database) is preserved.
Full reset (removes all data)
```bash
make clean
```
> **Warning:** this removes containers, images, and all stored data. The website will return to a blank state after the next `make`.
---
Accessing the website
Once the project is running:
Website: open your browser and go to:
```
https://<login>.42.fr
```
You will likely see a browser warning about the certificate — this is expected because the project uses a self-signed TLS certificate. Click "Advanced" and proceed to the site.
WordPress admin panel: go to:
```
https://<login>.42.fr/wp-admin
```
Log in with the administrator credentials (see below).
---
Credentials
Credentials are stored locally in the `secrets/` directory at the root of the project. This directory is never committed to Git.
What	File
WordPress admin login	`secrets/credentials.txt`
Database user password	`secrets/db_password.txt`
Database root password	`secrets/db_root_password.txt`
> **Important:** keep these files private. Do not share them or push them to any remote repository.
The WordPress administrator username is set in `srcs/.env` under `WP_ADMIN_USER`. Note that it cannot contain the words `admin` or `administrator`.
---
Checking that services are running correctly
Quick status check
```bash
docker ps
```
You should see three containers listed — `nginx`, `wordpress`, and `mariadb` — all with status `Up`.
Check if the website is responding
```bash
curl -k https://<login>.42.fr
```
If you get HTML back, the site is up. The `-k` flag skips certificate verification for self-signed certs.
View logs for a specific service
```bash
docker logs nginx
docker logs wordpress
docker logs mariadb
```
If a container keeps restarting, its logs will show the error message.
Check a specific container is healthy
```bash
docker inspect --format='{{.State.Status}}' nginx
```
Expected output: `running`
---
Managing the WordPress site
Once logged into the admin panel at `https://<login>.42.fr/wp-admin`, you can:
Create and edit posts and pages
Install themes and plugins
Manage users (there must always be at least two users: the administrator and one regular user)
Configure site settings
Users
The site has two default users:
Administrator: full access to the admin panel. Username is defined in `srcs/.env` as `WP_ADMIN_USER`.
Regular user: a standard editor/subscriber account. Username is defined as `WP_USER`.
To add more users, go to Users → Add New in the WordPress admin panel.
---
Troubleshooting
Symptom	What to try
Browser says "site can't be reached"	Run `docker ps` — check all containers are up; verify `/etc/hosts` has `127.0.0.1 <login>.42.fr`
Browser shows certificate warning	This is normal — accept it and continue
WordPress shows "Error establishing database connection"	The MariaDB container may still be starting up; wait 30 seconds and refresh
Admin login not working	Double-check credentials in `secrets/credentials.txt` and `srcs/.env`
Changes not saved / site behaving oddly	Check `docker logs wordpress` for PHP or WordPress errors
