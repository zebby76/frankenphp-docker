ARG DEBIAN_FRONTEND=noninteractive

USER root

ENV XDG_CONFIG_HOME="/app/etc" \
    XDG_DATA_HOME="/app/var/cache" \
    PHP_INI_SCAN_DIR="/usr/local/etc/php/conf.d:/app/etc/php/conf.d" \
    HOME=/home/default \
    TMPDIR=/app/tmp \
    PATH=/app/bin:/app/sbin:/usr/local/bin:/usr/bin:$PATH

WORKDIR /app

VOLUME /app/sbin/
VOLUME /app/var/
VOLUME /app/etc/
VOLUME /app/tmp/

COPY --from=hairyhenderson/gomplate:stable /gomplate /usr/bin/gomplate
COPY --chmod=664 --chown=1001:0 config/ /app/config/

COPY --chmod=775 --chown=root:root bin/ /usr/local/bin/

COPY --from=build /usr/local/lib/php/extensions /usr/local/lib/php/extensions
COPY --from=build /usr/local/include/php /usr/local/include/php

RUN mkdir -p /home/default \
             /app/var/lock \
             /app/var/log \
             /app/var/run \
             /app/var/cache/caddy \
             /app/etc/supervisor.d \
             /app/etc/caddy \
             /app/bin/container-entrypoint.d \
             /app/src \
             /app/tmp \
             /app/sbin ; \
    chmod +x /usr/local/bin/container-entrypoint \
             /usr/local/bin/wait-for-it ; \
    \
    ln /etc/frankenphp/Caddyfile /app/etc/caddy/Caddyfile ; \
    \
    apt update && apt upgrade -y ; \
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
                    python3 \
                    python3-pip \
                    groff \
                    supervisor \
                    libtidy5deb1 \
                    libzip4 \
                    dumb-init \
                    awscli && \
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
    chown -Rf 1001:0 /home/default /app ; \
    chmod -R ugo+rw /home/default /app ; \
    find /app -type d -exec chmod ugo+x {} \; 

USER 1001

ENTRYPOINT ["dumb-init","--","container-entrypoint"]

HEALTHCHECK --start-period=2s --interval=30s --timeout=5s --retries=3 \
  CMD supervisorctl status frankenphp | grep -q 'RUNNING' || exit 1

CMD ["/usr/bin/supervisord", "-c", "/app/etc/supervisord.conf"]