ARG PHP_VERSION_SELECTED=8.3

FROM php:${PHP_VERSION_SELECTED}-fpm

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    nano \
    libpng-dev \
    libonig-dev \
    libzip-dev \
    && rm -r /var/lib/apt/lists/* \
    && docker-php-ext-install -j$(nproc) \
        zip \
        pcntl

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
COPY --from=composer/composer /usr/bin/composer /usr/local/bin/composer

WORKDIR /var/www/html

EXPOSE 80

CMD ["php-fpm"]
