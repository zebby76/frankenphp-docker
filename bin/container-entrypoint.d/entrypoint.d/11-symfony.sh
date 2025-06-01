#!/usr/bin/env bash

export APP_LOG_DIR="/app/var/log"

APP_CACHE_DIR_DEFAULT="/app/var/cache"
export APP_CACHE_DIR=${APP_CACHE_DIR:-"${APP_CACHE_DIR_DEFAULT}"}

true
