# Used for prod build.
FROM php:8.2-fpm AS php


ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

# Install dependencies.
RUN apt-get update && apt-get install -y curl ca-certificates git unzip libpq-dev libcurl4-gnutls-dev nginx libonig-dev libmagickwand-dev librdkafka-dev supervisor postgresql-common \
        && install -d /usr/share/postgresql-common/pgdg \
        && curl -o /usr/share/postgresql-common/pgdg/apt.postgresql.org.asc --fail https://www.postgresql.org/media/keys/ACCC4CF8.asc \
        && sh -c "echo \"deb [signed-by=/usr/share/postgresql-common/pgdg/apt.postgresql.org.asc] https://apt.postgresql.org/pub/repos/apt \$(awk -F= '/VERSION_CODENAME/ { print \$2 }' /etc/os-release)-pgdg main\" > /etc/apt/sources.list.d/pgdg.list" \
        && apt update && apt -y install postgresql-client-16


RUN chmod +x /usr/local/bin/install-php-extensions \
     && install-php-extensions curl mysqli opcache pdo pdo_mysql exif bcmath intl pcntl zip mbstring gd \
        imagick mongodb rdkafka


# Copy composer executable.
COPY --from=composer:2.3.5 /usr/bin/composer /usr/bin/composer
