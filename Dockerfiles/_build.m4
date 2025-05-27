ARG DEBIAN_FRONTEND=noninteractive

ENV PHP_EXT_REDIS_VERSION=${PHP_EXT_REDIS_VERSION_ARG:-6.1.0} \
    PHP_EXT_APCU_VERSION=${PHP_EXT_APCU_VERSION_ARG:-5.1.24} \
    PHP_EXT_XDEBUG_VERSION=${PHP_EXT_XDEBUG_VERSION_ARG:-3.4.1}

RUN apt update ; \
    apt install -y --no-install-recommends \
                autoconf \
                libfreetype6-dev \
                libicu-dev \
                libjpeg-dev \
                libpng-dev \
                libwebp-dev \
                libxpm-dev \
                libzip-dev \
                libldap2-dev \
                libpcre3-dev \
                gnupg \
                git \
                libbz2-dev \
                gettext \
                libpq-dev \
                libxml2-dev \
                libtidy-dev \
                libxslt-dev \
                coreutils \
                $PHPIZE_DEPS

RUN docker-php-ext-configure gd --with-freetype --with-webp --with-jpeg \
    && docker-php-ext-configure tidy --with-tidy \
    && docker-php-ext-install -j "$(nproc)" soap bz2 gettext intl pcntl pgsql \
                                            pdo_pgsql ldap gd ldap mysqli pdo_mysql \
                                            zip bcmath exif tidy xsl calendar \
    && pecl install APCu-${PHP_EXT_APCU_VERSION} \
    && pecl install redis-${PHP_EXT_REDIS_VERSION} \
    && pecl install xdebug-${PHP_EXT_XDEBUG_VERSION}