FROM php:8-apache
RUN docker-php-ext-install mysqli && docker-php-ext-enable mysqli && apachectl restart
EXPOSE 80
