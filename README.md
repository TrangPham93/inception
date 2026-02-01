- Oracle VirtualBox is a so-called hosted hypervisor, While several hypervisors can normally be installed in parallel, do not attempt to run virtual machines from competing hypervisors at the same time. Oracle VirtualBox cannot track what another hypervisor is currently attempting to do on the same host, and especially if several products attempt to use hardware virtualization features such as VT-x, this can crash the entire host.
- VMs can easily be imported and exported using the Open Virtualization Format (OVF).
- Docker compose is a tool that allows you to define and manage multiple Docker containers simultaneously. If your app needs multiple services (like a web server, a database, and a caching service), Docker Compose helps you define and manage all these services together.
    Docker: You create individual containers for each part of your application. For example, one container for the web server, one for the database, and another for the caching service.
    Docker Compose: You define a docker-compose.yml file where you specify how these containers should work together. This file includes details like which images to use, the network settings, volumes, and environment variables.
    Running the Setup: With a single command (docker-compose up), Docker Compose starts and manages all the defined containers, ensuring they communicate and work together seamlessly.
- Docker images are read-only templates that contain instructions for creating a container. There are two important principles of images:

    Images are immutable. Once an image is created, it can't be modified. You can only make a new image or add changes on top of it.

    Container images are composed of layers. Each layer represents a set of file system changes that add, remove, or modify files.
    
    A Dockerfile is a text-based document that's used to create a container image.

https://devopscube.com/build-docker-image/

- Linux filesystem convention
| Path                    | Purpose                              |
| ----------------------- | ------------------------------------ |
| `/etc`                  | Configuration files                  |
| `/etc/nginx`            | NGINX configuration                  |
| `/etc/nginx/certs`      | TLS certificates (custom convention) |
| `/usr/share/nginx/html` | Static website content               |
| `/var/log/nginx`        | Logs                                 |
| `/run/nginx`            | Runtime files (PID, sockets)         |

- HTTPS works because three cryptographic objects work together
    HTTPS = encryption + identity
    Encryption comes from keys
    Identity comes from certificates
    
- A Certificate Authority is a trusted third party that:

    Verifies domain ownership

    Signs certificates

    Creates trust between browsers and servers

- to create free ca with openssl: openssl req -x509 -newkey rsa:4096 \
  -keyout server.key \
  -out server.crt \
  -days 365 -nodes
now the cert are saved on the folder run

- build docker and run: 
     docker rm -f webserver
     docker build -t nginx .
     docker run -d -p 443:443 --name webserver nginx
and to check what is runing: docker ps or docker images if existing

- Docker Compose is a tool for defining and running multi-container Docker applications using a YAML file.
    docker-compose up : run docker compose
    docker-compose --version : check docker exist
    
- 
FAQs
1. Why should I use Docker Compose for WordPress?

Using Docker Compose simplifies the installation process for WordPress. Instead of manually installing a LAMP (Linux, Apache, MySQL, PHP) or LEMP (Linux, Nginx, MySQL, PHP) stack, you can define your entire multi-container environment in a single docker-compose.yml file. This file coordinates all the services your application needs; in this case, a MySQL database, the WordPress application, and an Nginx web server. This method is less time-consuming and allows you to standardize the setup using pre-built images.
2. How are the Nginx web server and WordPress application connected?

The Nginx webserver container and the wordpress container are connected via a custom bridge network defined in the Compose file, named app-network. This network allows the containers to communicate securely. The Nginx configuration (nginx.conf) is set up to handle PHP processing by proxying requests. Specifically, any request matching \.php$ is passed to the wordpress container using the fastcgi_pass wordpress:9000; directive. This works because the wordpress container is running the wordpress:5.1.1-fpm-alpine image, which includes the php-fpm processor that Nginx needs.
3. How does this setup handle sensitive information like database passwords?

This setup securely manages sensitive information by separating it from the main configuration. All credentials, such as the MYSQL_ROOT_PASSWORD, MYSQL_USER, and MYSQL_PASSWORD, are stored in an .env file. The db and wordpress services in the docker-compose.yml file then reference this file using the env_file: .env directive. This prevents sensitive data from being hard-coded, publicly exposed, or accidentally committed to a Git repository. To further this, the tutorial recommends adding .env to .gitignore and .dockerignore files.
4. What is the process for obtaining an SSL certificate?

The setup uses a dedicated certbot container to get certificates from Let’s Encrypt.

    Initial Test: First, you run docker-compose up -d. The certbot service in the docker-compose.yml file initially includes the --staging flag. This tells Certbot to request a test certificate from Let’s Encrypt’s staging environment, which helps you avoid rate limits while ensuring your configuration is correct.
    Verification: You verify the test certificate was created by checking the webserver container’s /etc/letsencrypt/live directory.
    Live Certificate: Once you confirm the test was successful, you modify the certbot service command in your docker-compose.yml file. You remove the --staging flag and add --force-renewal.
    Final Request: You then run docker-compose up --force-recreate --no-deps certbot to stop the old certbot container, recreate it with the new command, and request the live, production-ready certificate.

5. How are the SSL certificates renewed automatically?

A shell script, ssl_renew.sh, is created on the host machine to automate the renewal process. This script:

    Changes to the project directory (~/wordpress).
    Runs $COMPOSE run certbot renew to check if the certificates are near expiration and renew them if necessary.
    Runs $COMPOSE kill -s SIGHUP webserver to send a SIGHUP signal to the Nginx container, which gracefully reloads its configuration and starts using the new certificate.
    This script is then scheduled to run automatically by adding it to the root crontab file, which sets it to execute at a defined interval (e.g., daily).

6. Will I lose my database and WordPress files if I stop the containers?

No, the setup is designed for data persistence using named volumes.

    The dbdata volume is mounted to /var/lib/mysql in the db container, storing all your MySQL database files.
    The wordpress volume is mounted to /var/www/html in both the wordpress and webserver containers, storing your WordPress core files, themes, plugins, and uploads.
    The certbot-etc volume stores your SSL certificates.

These volumes are managed by Docker on the host filesystem and are independent of the container’s lifecycle. This means you can stop, remove, or recreate the containers without losing any of your data.

- DNS (Domain Name System) is the internet's phonebook, translating human-friendly website names (like google.com) into numerical IP addresses (like 142.250.186.46) that computers use to find and connect to each other, making the web accessible without memorizing complex numbers

- need to match : trpham.42.fr to localhost in local machine

# Set up and validating an SSH(secure shell) connection
- SSH let you open a terminal section on another machine
- over secure, encrypted connection
´´´ ssh localhost -p 22´´´
- 

# virtual machine set up
root password: trpham4142
user: trpham. trpham4142

