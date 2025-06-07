#!/usr/bin/env bash

APP_LOG_DIR_DEFAULT="/app/var/log"
APP_CACHE_DIR_DEFAULT="/app/var/cache"

export APP_LOG_DIR=${APP_LOG_DIR:-"${APP_LOG_DIR_DEFAULT}"}
export APP_CACHE_DIR=${APP_CACHE_DIR:-"${APP_CACHE_DIR_DEFAULT}"}

true
