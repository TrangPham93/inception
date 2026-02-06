#!/bin/sh

# make the script stop immediately if any cmd fails
set -e

# Initialize database if empty
if [ ! -d "/var/lib/mysql/mysql" ]; then
	echo "Initializing MariaDB database..."
	mariadb-install-db --user=mysql --datadir=/var/lib/mysql

	# mariadb-safe is a wrapper with extra safety features that restarts mariadbd if mariadbd crashes
	# start mariadb temporarily and save the processID of the mariadb background 
	mariadbd-safe --datadir=/var/lib/mysql &
	pid="$!"

	# wait for mariadb to start
	sleep 5

	# set up root password and create database/user
	mariadb -e "CREATE DATABASE IF NOT EXISTS ${WORDPRESS_DATABASE_NAME};"
	mariadb -e "CREATE USER IF NOT EXISTS '${WORDPRESS_DATABASE_USER}' IDENTIFIED BY '${WORDPRESS_DATABASE_USER_PASSWORD}';"
	mariadb -e "GRANT ALL PRIVILEGES ON ${WORDPRESS_DATABASE_NAME}.* TO '${WORDPRESS_DATABASE_USER}'@'%';"
	mariadb -e "FLUSH PRIVILEGES;"

	#stop temporary server
	kill "$pid"
	wait "$pid"
fi

echo "Starting MariaDB..."
# --console outputs logs to stdout so Docker can show logs
exec mariadbd --user=mysql --console