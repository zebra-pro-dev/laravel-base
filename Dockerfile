# Used for prod build.
FROM php:8.2-fpm-bookworm AS php
ARG NODE_VERSION=20
ARG POSTGRES_VERSION=16

ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

# Install dependencies.
RUN apt-get update && apt-get install -y gnupg gosu curl ca-certificates git unzip libpq-dev libcurl4-gnutls-dev nginx libonig-dev libmagickwand-dev librdkafka-dev supervisor postgresql-common \
        && install -d /usr/share/postgresql-common/pgdg \
        && curl -o /usr/share/postgresql-common/pgdg/apt.postgresql.org.asc --fail https://www.postgresql.org/media/keys/ACCC4CF8.asc \
        && sh -c "echo \"deb [signed-by=/usr/share/postgresql-common/pgdg/apt.postgresql.org.asc] https://apt.postgresql.org/pub/repos/apt \$(awk -F= '/VERSION_CODENAME/ { print \$2 }' /etc/os-release)-pgdg main\" > /etc/apt/sources.list.d/pgdg.list" \
        && apt update && apt -y install postgresql-client-16 \
        && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
        && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_VERSION.x nodistro main" > /etc/apt/sources.list.d/nodesource.list \
        && apt-get update \
        && apt-get install -y nodejs \
        && apt-get install -y default-mysql-client \
        && npm install -g npm \
        && npm install -g pnpm \
        && apt-get -y autoremove \
        && curl https://install.duckdb.org | sh \
        && apt-get clean \
        && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


RUN chmod +x /usr/local/bin/install-php-extensions \
     && install-php-extensions curl mysqli opcache pdo pdo_mysql pdo_pgsql pgsql exif bcmath intl pcntl zip mbstring gd
             

RUN install-php-extensions  imagick
RUN install-php-extensions  mongodb
RUN install-php-extensions  rdkafka
# RUN install-php-extensions  grpc

COPY --from=cobiro/php:8.2-service-grpc /usr/local/lib/php/extensions/no-debug-non-zts-20220829/grpc.so /usr/local/lib/php/extensions/no-debug-non-zts-20220829/

# Copy the gRPC PHP configuration file
COPY --from=cobiro/php:8.2-service-grpc /usr/local/etc/php/conf.d/docker-php-ext-grpc.ini /usr/local/etc/php/conf.d/docker-php-ext-grpc.ini


# RUN install-php-extensions  redis
COPY --from=cobiro/php:8.2-service-grpc /usr/local/lib/php/extensions/no-debug-non-zts-20220829/redis.so /usr/local/lib/php/extensions/no-debug-non-zts-20220829/

# Copy the gRPC PHP configuration file
COPY --from=cobiro/php:8.2-service-grpc /usr/local/etc/php/conf.d/docker-php-ext-redis.ini /usr/local/etc/php/conf.d/docker-php-ext-redis.ini

RUN install-php-extensions  swoole

# Copy composer executable.
COPY --from=composer:2.3.5 /usr/bin/composer /usr/bin/composer
