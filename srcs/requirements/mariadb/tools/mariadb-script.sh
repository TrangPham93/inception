#!/bin/sh

# make the script stop immediately if any cmd fails
set -e

chmod -R 755 /var/lib/mysql

mkdir -p /run/mysqld

chown -R mysql:mysql /var/lib/mysql /run/mysqld

# Initialize database if empty
if [ ! -d "/var/lib/mysql/mysql" ]; then
	echo "Initializing MariaDB database..."
	mariadb-install-db --basedir=/usr --user=mysql --datadir=/var/lib/mysql

	# set up root password and create database/user
	echo "==> Creating WordPress database and user..."
	# pipe SQL into MariaDB during bootstrap.
	mysqld --user=mysql --bootstrap << EOF
USE mysql;
FLUSH PRIVILEGES;

ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';


CREATE DATABASE IF NOT EXISTS ${WORDPRESS_DATABASE_NAME};
CREATE USER IF NOT EXISTS ${WORDPRESS_DATABASE_USER}@'%' IDENTIFIED BY '${WORDPRESS_DATABASE_USER_PASSWORD}';
GRANT ALL PRIVILEGES ON ${WORDPRESS_DATABASE_NAME}.* TO ${WORDPRESS_DATABASE_USER}@'%';
FLUSH PRIVILEGES;
EOF

else
    echo "==> MariaDB is already installed. Database and users are configured."
fi

echo "Starting MariaDB..."
# --console outputs logs to stdout so Docker can show logs
exec mariadbd --user=mysql --console
### ALTER USER 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';