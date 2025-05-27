ARG DEBIAN_FRONTEND=noninteractive

USER root

RUN cp "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini" 

USER 1001