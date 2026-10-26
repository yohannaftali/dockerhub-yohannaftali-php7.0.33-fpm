ARG DEBIAN_RELEASE=trixie
FROM debian:${DEBIAN_RELEASE}-slim

# PHP minor version from https://packages.sury.org/php/ (Ondřej Surý); 7.0 is 7.0.33 + backported fixes
ARG PHP_VERSION=7.0

LABEL org.opencontainers.image.title="php7.0.33-fpm" \
      org.opencontainers.image.description="PHP 7.0.33-FPM (Debian, Ondřej Surý packages) for legacy CodeIgniter 2 apps with Composer 2.2, OS timezone Asia/Jakarta, PHP stays UTC" \
      org.opencontainers.image.authors="Yohan Naftali" \
      org.opencontainers.image.source="https://github.com/yohannaftali/dockerhub-yohannaftali-php7.0.33-fpm"

ENV TZ="Asia/Jakarta"
ENV DEBIAN_FRONTEND="noninteractive"

RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        tzdata \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone \
    && curl -fsSLo /tmp/debsuryorg-archive-keyring.deb https://packages.sury.org/debsuryorg-archive-keyring.deb \
    && dpkg -i /tmp/debsuryorg-archive-keyring.deb \
    && rm /tmp/debsuryorg-archive-keyring.deb \
    && . /etc/os-release \
    && echo "deb [signed-by=/usr/share/keyrings/debsuryorg-archive-keyring.gpg] https://packages.sury.org/php/ $VERSION_CODENAME main" \
        > /etc/apt/sources.list.d/php.list \
    && apt-get update && apt-get install -y --no-install-recommends \
        php${PHP_VERSION}-fpm \
        php${PHP_VERSION}-cli \
        php${PHP_VERSION}-bcmath \
        php${PHP_VERSION}-curl \
        php${PHP_VERSION}-gd \
        php${PHP_VERSION}-intl \
        php${PHP_VERSION}-mbstring \
        php${PHP_VERSION}-mcrypt \
        php${PHP_VERSION}-mysql \
        php${PHP_VERSION}-pgsql \
        php${PHP_VERSION}-soap \
        php${PHP_VERSION}-xml \
        php${PHP_VERSION}-xmlrpc \
        php${PHP_VERSION}-zip \
        jpegoptim optipng pngquant gifsicle \
        ssmtp \
        zip \
        unzip \
        nano \
        wget \
        iputils-ping \
        nmap \
    && rm -rf /var/lib/apt/lists/*

# Behave like the official php:*-fpm image: `php-fpm` in the foreground on port 9000, logs to stderr
RUN ln -s /usr/sbin/php-fpm${PHP_VERSION} /usr/local/sbin/php-fpm \
    && mkdir -p /run/php /var/www/html \
    && chown www-data:www-data /var/www/html \
    && { \
        echo '[global]'; \
        echo 'daemonize = no'; \
        echo 'error_log = /proc/self/fd/2'; \
        echo; \
        echo '[www]'; \
        echo 'listen = 9000'; \
        echo 'access.log = /proc/self/fd/2'; \
        echo 'clear_env = no'; \
        echo 'catch_workers_output = yes'; \
    } > /etc/php/${PHP_VERSION}/fpm/pool.d/zz-docker.conf

# Debian's PHP falls back to the system timezone (TZ) when date.timezone is unset; keep PHP on UTC
RUN for sapi in cli fpm; do \
        echo 'date.timezone = UTC' > /etc/php/${PHP_VERSION}/$sapi/conf.d/zz-docker-timezone.ini; \
    done

COPY --from=composer:2.2 /usr/bin/composer /usr/local/bin/composer

WORKDIR /var/www/html
STOPSIGNAL SIGQUIT
EXPOSE 9000
CMD ["php-fpm"]
