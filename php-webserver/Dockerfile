FROM php:8-apache
COPY custom.ini $PHP_INI_DIR/conf.d/
RUN docker-php-ext-install mysqli && docker-php-ext-enable mysqli && apachectl restart
EXPOSE 80
