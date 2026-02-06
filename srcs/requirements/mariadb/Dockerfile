FROM alpine:3.22

# Install MariaDB database and client tools
RUN	apk update && apk add mariadb mariadb-client

COPY ./conf/mariadb_config /etc/my.cnf.d/mariadb_config
RUN chmod 664 /etc/my.cnf.d/mariadb_config

COPY ./tools/mariadb-script.sh /usr/local/bin/mariadb-script.sh 
RUN chmod +x /usr/local/bin/mariadb-script.sh

EXPOSE 3306

ENTRYPOINT ["mariadb-script.sh"]
 