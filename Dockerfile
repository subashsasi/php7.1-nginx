FROM ubuntu:18.04
LABEL maintainer="subash.s@iinerds.com"
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
# Copying configuration files
COPY conf/nginx/default /etc/nginx/sites-available/
COPY conf/nginx/nginx.conf /etc/nginx/
COPY conf/supervisord.conf /etc/supervisor/
COPY conf/php/php-fpm.conf /etc/php/7.1/fpm/
COPY conf/php/php.ini /etc/php/7.1/fpm/
COPY conf/php/www.conf /etc/php/7.1/fpm/pool.d/
COPY index.php /var/www/html
# Giving permission to datafolder and fpm log folder
RUN mkdir -p /var/run/php /var/log/php7.1-fpm && \
    chown -R www-data:www-data /var/run/php /var/www/html /var/log/php7.1-fpm && \
    chmod -R 775 /var/www/html /var/run/php /var/log/php7.1-fpm
# Diverting fpm logs and nginx logs to stdout
RUN ln -sf /dev/stdout /var/log/nginx/error.log \
	&& ln -sf /dev/stderr /var/log/php7.1-fpm/error.log
# Clean up
RUN apt-get clean
WORKDIR /var/www/html/
EXPOSE 80
CMD ["supervisord", "-c", "/etc/supervisor/supervisord.conf"]
