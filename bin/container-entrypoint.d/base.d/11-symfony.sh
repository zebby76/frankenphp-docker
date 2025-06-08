#!/usr/bin/env bash

log "INFO" "| Configure Symfony ..."

OUTDIR="${APP_LOG_DIR} ${APP_CACHE_DIR}"
mkdir -p $OUTDIR
