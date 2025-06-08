#!/usr/bin/env bash

log "INFO" "| Configure PHP ..."

OUTDIR="/opt/etc/php/conf.d"
mkdir -p $OUTDIR

apply-template /opt/config/php/conf.d/00-base.ini.tmpl ${OUTDIR}/00-base.ini

true
