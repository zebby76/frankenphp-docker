#!/usr/bin/env bash

log "INFO" "| Configure FrankenPHP ..."

OUTDIR="/app/etc/caddy/Caddyfile.d /app/var/cache/caddy"
mkdir -p $OUTDIR

apply-template /app/config/caddy/Caddyfile.d /app/etc/caddy/Caddyfile.d

true
