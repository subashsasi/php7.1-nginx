FROM ubuntu:18.04
MAINTAINER subash.s@iinerds.com
ENV DEBIAN_FRONTEND=noninteractive
# Main package installation
RUN apt-get update && \
    apt-get install -y software-properties-common && \
    apt-add-repository ppa:ondrej/php && \
    apt-get update && \
    apt-get install -y supervisor php7.1-fpm nginx php7.1-cli python-pip && \
    pip install supervisor-stdout
# Extra package installation
RUN apt-get install -y php7.1-gd php7.1-apcu php7.1-curl php-pear php7.1-mysqli php7.1-common && \
    rm -rf /var/lib/apt/lists/*
# Copying configuration files
COPY conf/nginx/default /etc/nginx/sites-available/
COPY conf/nginx/nginx.conf /etc/nginx/
COPY conf/supervisord.conf /etc/supervisor/
COPY conf/php/php-fpm.conf /etc/php/7.1/fpm/
COPY conf/php/php.ini /etc/php/7.1/fpm/
COPY conf/php/www.conf /etc/php/7.1/fpm/pool.d/
COPY index.php /var/www/html
# Giving permission to datafolder and php-fpm socket folder
RUN mkdir -p /var/run/php && \
    chown -R www-data:www-data /var/run/php /var/www/html && \
    chmod -R 775 /var/www/html /var/run/php
# Clean up
RUN apt-get clean
WORKDIR /var/www/html/
EXPOSE 80
CMD ["supervisord", "-c", "/etc/supervisor/supervisord.conf"]
