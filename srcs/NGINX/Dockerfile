FROM alpine:3.22

# Install the application dependencies
RUN  apk add --no-cache nginx && mkdir -p /run/nginx

# Copy in the source code
COPY files/default /etc/nginx/http.d/default.conf
COPY files/index.html /usr/share/nginx/html/index.html

EXPOSE 80


# 
CMD [ "/usr/sbin/nginx", "-g", "daemon off;" ]