#!/bin/sh

set -e

DATADIR="/var/lib/mysql"
RUNDIR="/run/mysqld"
LOGDIR="/var/log/mysql"
CONFIG_FILE="/etc/my.cnf.d/mariadb_config.cnf"
INIT_FILE="${DATADIR}/init.sql"

mkdir -p "${DATADIR}" "${RUNDIR}" "${LOGDIR}"
chown -R mysql:mysql "${DATADIR}" "${RUNDIR}" "${LOGDIR}"

# chmod 750 /var/lib/mysql
# chown -R mysql:mysql /var/lib/mysql /run/mysqld

# Initialize database if empty
if [ ! -d "${DATADIR}/mysql" ]; then
	echo "Initializing MariaDB database..."
	mariadb-install-db --basedir=/usr --user=mysql --datadir="${DATADIR} --skip-test-db"
fi
	# # set up root password and create database/user
	# echo "==> Creating WordPress database and user..."
	# # pipe SQL into MariaDB during bootstrap.
	# mysqld --user=mysql --bootstrap << EOF

USE mysql;

# FLUSH PRIVILEGES;
echo "Preparing init SQL"
cat > "${INIT_FILE}" << EOF

ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
CREATE DATABASE IF NOT EXISTS ${WORDPRESS_DATABASE_NAME} CHARACTER SET utf8 COLLATE utf8_general_ci;
CREATE USER IF NOT EXISTS ${WORDPRESS_DATABASE_USER}@'%' IDENTIFIED BY '${WORDPRESS_DATABASE_USER_PASSWORD}';
GRANT ALL PRIVILEGES ON ${WORDPRESS_DATABASE_NAME}.* TO ${WORDPRESS_DATABASE_USER}@'%';
FLUSH PRIVILEGES;
EOF

chown mysql:mysql "${INIT_FILE}"

echo "Starting MariaDB..."

# sleep 5
# --console outputs logs to stdout so Docker can show logs
# exec mariadbd --user=mysql --console
### ALTER USER 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
exec mariadbd --defaults-file="${CONFIG_FILE}" --init-file="${INIT_FILE}" --console




