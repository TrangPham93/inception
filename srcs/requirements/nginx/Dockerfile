FROM alpine:3.22

# Install the application dependencies
RUN apk update && apk add nginx openssl

EXPOSE 443 

RUN mkdir -p /etc/nginx/certs
RUN openssl req -x509 -nodes \
    -out /etc/nginx/certs/public_certificate.crt \
    -keyout /etc/nginx/certs/private.key \
    -subj "/C=FI/ST=Uusimaa/L=Helsinki/O=42/OU=Hive/CN=trpham.42.fr"

# Create a new user (www-data) for running Nginx
RUN adduser -D -H -s /sbin/nologin -g www-data -G www-data www-data

# Copy Nginx configuration file
COPY ./conf/nginx.conf /etc/nginx/nginx.conf 
RUN chmod 664 /etc/nginx/nginx.conf

CMD ["nginx", "-c", "/etc/nginx/nginx.conf", "-g", "daemon off;" ]
