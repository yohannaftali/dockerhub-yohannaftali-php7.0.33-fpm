FROM php:7.0.33-fpm-alpine


ENV TZ="Asia/Jakarta"
ENV DEBIAN_FRONTEND="noninteractive"

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apk update && apk add --no-cache \
    build-base \
    curl-dev \
    freetype-dev \
    icu-dev \
    jpeg-dev \
    libmcrypt-dev \
    php7-mcrypt \
    oniguruma-dev \
    libpng-dev \
    postgresql-dev \
    libwebp-dev \
    libxml2-dev \
    libzip-dev \
    jpegoptim optipng pngquant gifsicle \
    ssmtp \
    zip \
    unzip \
    zlib-dev \
    nano \
    wget \
    curl \
    iputils \
    nmap

RUN docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg
RUN docker-php-ext-configure intl
RUN docker-php-ext-configure zip
RUN docker-php-ext-install -j$(nproc) \ 
    gd \
    mysqli \
    pdo \
    pdo_mysql \
    pgsql \
    pdo_pgsql \
    zip \
    soap \
    bcmath \
    mbstring \
    pcntl \
    xmlrpc \
    intl \
    mcrypt
RUN docker-php-ext-enable \
    mysqli \
    pdo \   
    pdo_mysql \
    pgsql \
    pdo_pgsql \
    mcrypt
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer