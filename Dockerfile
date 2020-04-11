FROM ubuntu:18.04
MAINTAINER subash.s@iinerds.com
ENV DEBIAN_FRONTEND=noninteractive
# Main package installation
RUN apt-get update && \
    apt-get install -y software-properties-common && \
    apt-add-repository ppa:ondrej/php && \
    apt-get update && \
    apt-get install -y supervisor php7.1-fpm nginx php7.1-cli php7.1-common
# Extra package installation
RUN apt-get install -y php7.1-gd php7.1-apcu php7.1-curl php-pear php7.1-mysqli && \
    rm -rf /var/lib/apt/lists/*
# Nginx configuration
COPY conf/default /etc/nginx/sites-available/
COPY conf/nginx.conf    /etc/nginx/
# Supervisor configuration files
COPY conf/supervisord.conf /etc/supervisor/
# PHP FPM configuration
RUN sed -i 's/;daemonize = yes/daemonize = no/g' /etc/php/7.1/fpm/php-fpm.conf
RUN sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /etc/php/7.1/fpm/php.ini
RUN mkdir -p /run/php && \
    chown -R www-data:www-data /run/php /var/www/html && \
    chmod -R 775 /var/www/html /run/php
# Clean up
RUN apt-get clean
WORKDIR /var/www/html/
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
	&& ln -sf /dev/stderr /var/log/nginx/error.log
EXPOSE 80
CMD ["supervisord", "-c", "/etc/supervisor/supervisord.conf"]
