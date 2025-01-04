# Used for prod build.
FROM php:8.2-fpm AS php


ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

# Install dependencies.
RUN apt-get update && apt-get install -y git unzip libpq-dev libcurl4-gnutls-dev nginx libonig-dev libmagickwand-dev librdkafka-dev 

RUN chmod +x /usr/local/bin/install-php-extensions \
     && install-php-extensions curl mysqli opcache pdo pdo_mysql exif bcmath intl pcntl zip mbstring gd \
        imagick mongodb rdkafka


# Copy composer executable.
COPY --from=composer:2.3.5 /usr/bin/composer /usr/bin/composer