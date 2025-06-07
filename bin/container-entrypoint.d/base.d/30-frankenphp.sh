#!/usr/bin/env bash

log "INFO" "| Configure FrankenPHP ..."

OUTDIR="/opt/etc/caddy/Caddyfile.d /app/var/cache/caddy"
mkdir -p $OUTDIR

apply-template /opt/config/caddy/Caddyfile.tmpl /opt/etc/caddy/Caddyfile
apply-template /opt/config/caddy/Caddyfile.d /opt/etc/caddy/Caddyfile.d

true
