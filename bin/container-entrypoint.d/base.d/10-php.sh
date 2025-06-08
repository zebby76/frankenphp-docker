#!/usr/bin/env bash

log "INFO" "| Configure PHP ..."

OUTDIR="/opt/etc/php/conf.d"
mkdir -p $OUTDIR

apply-template /opt/config/php/conf.d/00-base.ini.tmpl /opt/etc/php/conf.d/00-base.ini
apply-template /opt/config/php/conf.d/00-base.opcache.ini.tmpl /opt/etc/php/conf.d/00-base.opcache.ini

if [[ "${PHP_XDEBUG_ENABLE}" == "true" ]]; then
  apply-template /opt/config/php/conf.d/00-base.xdebug.ini.tmpl /opt/etc/php/conf.d/00-base.xdebug.ini
fi

true
