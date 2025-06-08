# syntax=docker/dockerfile:1.15
ARG REL_ARG

ARG PHP_VERSION_ARG
ARG NODE_VERSION_ARG
ARG COMPOSER_VERSION_ARG
ARG FRANKENPHP_VERSION_ARG
ARG GOMPLATE_VERSION_ARG

FROM hairyhenderson/gomplate:v${GOMPLATE_VERSION_ARG} AS gomplate
FROM composer:${COMPOSER_VERSION_ARG} AS composer
FROM node:${NODE_VERSION_ARG} AS node
FROM dunglas/frankenphp:${FRANKENPHP_VERSION_ARG}-php${PHP_VERSION_ARG}-${REL_ARG} AS upstream

FROM upstream AS build

ARG PHP_EXT_REDIS_VERSION_ARG
ARG PHP_EXT_APCU_VERSION_ARG
ARG PHP_EXT_XDEBUG_VERSION_ARG

ARG DEBIAN_FRONTEND=noninteractive

ENV PHP_EXT_REDIS_VERSION=${PHP_EXT_REDIS_VERSION_ARG} \
    PHP_EXT_APCU_VERSION=${PHP_EXT_APCU_VERSION_ARG} \
    PHP_EXT_XDEBUG_VERSION=${PHP_EXT_XDEBUG_VERSION_ARG}

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

FROM upstream AS common

LABEL org.opencontainers.image.title="ZeBBy76 FrankenPHP" \
      org.opencontainers.image.authors="sebastian.molle@gmail.com" \
      org.opencontainers.image.source="https://github.com/zebby76/frankenphp-docker"

ARG AWSCLI_VERSION_ARG
ARG AWSCLI_ARCH_ARG

ARG DEBIAN_FRONTEND=noninteractive

ENV XDG_CONFIG_HOME="/opt/etc" \
    XDG_DATA_HOME="/app/var/cache" \
    PHP_INI_SCAN_DIR="/usr/local/etc/php/conf.d:/opt/etc/php/conf.d" \
    HOME=/home/default \
    TMPDIR=/app/tmp \
    PATH=/opt/bin:/opt/sbin:/usr/local/bin:/usr/bin:$PATH

WORKDIR /app

VOLUME /opt/sbin
VOLUME /opt/etc
VOLUME /app/var
VOLUME /app/tmp

COPY --chmod=664 --chown=1001:0 config/ /opt/config/

COPY --chmod=775 --chown=root:root bin/ /usr/local/bin/

COPY --from=build /usr/local/lib/php/extensions /usr/local/lib/php/extensions
COPY --from=build /usr/local/include/php /usr/local/include/php
COPY --from=gomplate /gomplate /usr/bin/gomplate

RUN apt update && apt upgrade -y ; \
    apt-get install -y --no-install-recommends \
        unzip \
        groff \
        less ; \
    mkdir -p /tmp/aws ; \
    curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-${AWSCLI_ARCH_ARG}-${AWSCLI_VERSION_ARG}.zip" | \
    unzip -d /tmp/aws ; \
    /tmp/aws/install --update --install-dir /usr/local/aws-cli --bin-dir /usr/local/bin ; \
    rm -rf /tmp/aws ; 

RUN mkdir -p /opt/bin \
             /opt/sbin \
             /opt/etc/supervisor.d \
             /opt/etc/caddy \
             /opt/bin/container-entrypoint.d \
             /home/default \
             /app/var/lock \
             /app/var/log \
             /app/var/run \
             /app/var/cache/caddy \
             /app/tmp ; \
    chmod +x /usr/local/bin/container-entrypoint \
             /usr/local/bin/wait-for-it ; \
    \
    apt-get install -y --no-install-recommends \
                    libnss3-tools \
                    procps \
                    tzdata \
                    bash \
                    gettext-base \
                    postgresql-client \
                    libpq5 \
                    libjpeg62-turbo \
                    libfreetype6 \
                    libpng16-16 \
                    libwebp7 \
                    libxpm4 \
                    bsd-mailx \
                    libxslt1.1 \
                    coreutils \
                    default-mysql-client \
                    jq \
                    libicu72 \
                    libxml2 \
                    supervisor \
                    libtidy5deb1 \
                    libzip4 \
                    dumb-init && \
    rm -rf /var/lib/apt/lists/* ; \
    \
    docker-php-ext-enable soap \
                          bz2 \
                          gettext \
                          intl \
                          pcntl \
                          pgsql \
                          pdo_pgsql \
                          gd \
                          ldap \
                          mysqli \
                          pdo_mysql \
                          zip \
                          bcmath \
                          exif \
                          tidy \
                          xsl \
                          calendar \
                          apcu \
                          redis \
                          opcache ; \
    \
    touch /app/var/log/supervisord.log \
          /app/var/run/supervisord.pid ; \
    \
    ln -snf /usr/share/zoneinfo/Europe/Brussels /etc/localtime ; \
    echo "Europe/Brussels" > /etc/timezone ; \
    dpkg-reconfigure -f noninteractive tzdata ; \
    \
    groupadd -g 1001 default ; \
    useradd -u 1001 -g 1001 -G root -s /usr/sbin/nologin -m default ; \
    \
    chown -Rf 1001:0 /home/default /app /opt ; \
    chmod -R 775 /home/default /app /opt ; 

ENTRYPOINT ["dumb-init","--","container-entrypoint"]

HEALTHCHECK --start-period=2s --interval=30s --timeout=5s --retries=3 \
  CMD supervisorctl status frankenphp | grep -q 'RUNNING' || exit 1

CMD ["/usr/bin/supervisord", "-c", "/opt/etc/supervisord.conf"]

FROM common AS prd

RUN cp "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

USER 1001

FROM prd AS dev

EXPOSE 9003/tcp

ENV PHP_XDEBUG_MODE="develop"

COPY --from=composer /usr/bin/composer /usr/bin/composer

COPY --from=node /usr/lib /usr/lib
COPY --from=node /usr/local/share /usr/local/share
COPY --from=node /usr/local/lib /usr/local/lib
COPY --from=node /usr/local/include /usr/local/include
COPY --from=node /usr/local/bin /usr/local/bin

RUN cp "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini" ; \
    docker-php-ext-enable xdebug ; \
    mkdir /home/default/.composer ; \
    chown 1001:0 /home/default/.composer ; \
    chmod -R ugo+rw /home/default/.composer

USER 1001
