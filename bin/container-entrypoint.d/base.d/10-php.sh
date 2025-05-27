#!/usr/bin/env bash

log "INFO" "| Configure PHP ..."

OUTDIR="/app/etc/php/conf.d"
mkdir -p $OUTDIR

apply-template /app/config/php/conf.d/00-base.ini.tmpl /app/etc/php/conf.d/00-base.ini
apply-template /app/config/php/conf.d/00-base.opcache.ini.tmpl /app/etc/php/conf.d/00-base.opcache.ini

if [[ "${PHP_XDEBUG_ENABLE_DEFAULT}" == "true" ]]; then
  apply-template /app/config/php/conf.d/00-base.xdebug.ini.tmpl /app/etc/php/conf.d/00-base.xdebug.ini
fi

true
