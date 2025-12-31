FROM alpine:3.22

# Install MariaDB server
RUN	apk add --no-cache mysql-server

ARG mariadb-configuration-file

ENTRYPOINT mariadb --default-file=${mariadb-configuration-file}