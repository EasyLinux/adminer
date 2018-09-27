FROM alpine:3.8
LABEL maintainer="Serge NOEL <serge.noel@easylinux.fr>"

# Install webserver & Php
RUN apk update\
    && apk add --no-cache curl nginx php7 php7-fpm php7-mysqli php7-apcu supervisor php7-opcache php7-session php7-xmlrpc \
    && mkdir -p /run/nginx

ADD Files /

# Apply PHP FPM configuration
RUN sed -i -e "s|;daemonize\s*=\s*yes|daemonize = no|g" /etc/php7/php-fpm.conf && \
    sed -i -e "s|display_errors = Off|display_errors = stderr|" /etc/php7/php.ini && \
    sed -i -e "s|display_startup_errors = Off|display_startup_errors = On|" /etc/php7/php.ini && \
    sed -i -e "s|user\s*=\s*nobody|user = nginx|g" /etc/php7/php-fpm.d/www.conf && \
    sed -i -e "s|group\s*=\s*nobody|group = nginx|g" /etc/php7/php-fpm.d/www.conf && \
    sed -i -e "s|listen\s*=\s*127\.0\.0\.1:9000|listen = /var/run/php-fpm.sock|g" /etc/php7/php-fpm.d/www.conf && \
    sed -i -e "s|;listen\.owner\s*=\s*.*$|listen.owner = nginx|g" /etc/php7/php-fpm.d/www.conf && \
    sed -i -e "s|;listen\.group\s*=.*$|listen.group = nginx|g" /etc/php7/php-fpm.d/www.conf && \
    sed -i -e "s|;listen\.mode\s*=\s*|listen.mode = |g" /etc/php7/php-fpm.d/www.conf && \
    sed -i -e "s|max_execution_time\s*=.*$|max_execution_time = 600|" /etc/php7/php.ini && \
    sed -i -e "s|upload_max_filesize\s*=.*$|upload_max_filesize = 30M|" /etc/php7/php.ini && \
    chown -R nginx.nginx /var/www && \
    chmod -R g=rX,o=--- /var/www

EXPOSE 80/tcp

HEALTHCHECK --interval=5s --timeout=3s --retries=3 \
    CMD curl --silent --fail http://localhost:80 || exit 1

CMD ["/usr/bin/supervisord","-c","/etc/supervisor/supervisord.conf"]
