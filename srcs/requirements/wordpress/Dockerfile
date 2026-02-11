FROM alpine:3.20.6

RUN apk update && apk add mariadb-client \
    php83 \
	php83-fpm \
	php83-phar \
	php83-curl \
	php83-mysqli \
	php83-iconv \
    php83-json \
	wget 

# RUN  ln -s /usr/bin/php83 /usr/bin/php


# Create a www-data user
RUN adduser -D -H -s /sbin/nologin -g www-data -G www-data www-data

RUN mkdir -p /var/www/wp /var/www/html

# Copy PHP-FPM configuration
COPY conf/www.conf /etc/php83/php-fpm.d/www.conf

# Copy wordpress setup script
COPY tools/wordpress-script.sh /usr/local/bin/wordpress-script.sh
RUN chmod +x /usr/local/bin/wordpress-script.sh

WORKDIR /var/www/html

EXPOSE 9000

ENTRYPOINT [ "wordpress-script.sh" ]