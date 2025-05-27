ARG DEBIAN_FRONTEND=noninteractive

EXPOSE 9003/tcp

ENV PHP_XDEBUG_ENABLED="true"

USER root

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