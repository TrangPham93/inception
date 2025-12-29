FROM alpine:3.22

# Install the application dependencies
RUN	apk add --no-cache nginx && mkdir -p /run/nginx
RUN mkdir -p /etc/nginx/certs


# Copy in the source code
COPY tools/server.crt /etc/nginx/certs/server.crt
COPY tools/server.key /etc/nginx/certs/server.key
COPY conf/default.conf /etc/nginx/http.d/default.conf
COPY conf/index.html /usr/share/nginx/html/index.html

EXPOSE 443

# allow nginx to own and access to this file inside the container
RUN chown -R nginx:nginx /usr/share/nginx/html \
    && chmod -R 755 /usr/share/nginx/html

CMD [ "/usr/sbin/nginx", "-g", "daemon off;" ]