# Dockerfile - PHP-FPM for Laravel
FROM php:8.3-fpm

RUN apt-get update && apt-get install -y \
    git unzip libzip-dev libonig-dev libpq-dev libpng-dev zlib1g-dev libxml2-dev \
  && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip

# install composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

# copy app later via volume or build context
