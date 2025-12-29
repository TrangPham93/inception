FROM alpine:3.22

# Install the application dependencies
RUN	apk add --no-cache mariadb-server

ARG mariadb-configuration-file

ENTRYPOINT mariadb --default-file=${mariadb-configuration-file}