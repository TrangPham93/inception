FROM alpine:3.22
WORKDIR /the/workdir/path

# Install the application dependencies
RUN apt-get -y update && apt-get -y install nginx

# Copy in the source code
COPY files/index.html usr/share/nginx/html/index.html
EXPOSE 443


# 
CMD [ "usr/sbin/nginx", "-g", "deamon off;" ]