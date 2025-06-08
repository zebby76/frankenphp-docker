#!/usr/bin/env bash

OUTDIR="${BASE_BIN_DIR} ${BASE_VAR_DIR} ${BASE_ETC_DIR} ${BASE_TMP_DIR}"

log "INFO" "| Configure Symfony ... "
log "INFO" "| $(ls -ld ${OUTDIR}) "

# for dir in ${OUTDIR}; do
#   setfacl -R -m u:"$(whoami)":rwX "$dir"
#   setfacl -dR -m u:"$(whoami)":rwX "$dir"
# done

true
