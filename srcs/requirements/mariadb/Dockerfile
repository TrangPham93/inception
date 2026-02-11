FROM alpine:3.20.6

# Install MariaDB database and client tools
RUN	apk update && apk add mariadb mariadb-client

RUN rm -f /etc/my.cnf || true

COPY conf/mariadb.cnf /etc/my.cnf.d/mariadb.cnf
RUN chmod 664 /etc/my.cnf.d/mariadb.cnf

COPY tools/mariadb-script.sh /usr/local/bin/mariadb-script.sh 
RUN chmod +x /usr/local/bin/mariadb-script.sh

EXPOSE 3306

ENTRYPOINT ["/usr/local/bin/mariadb-script.sh"]
 