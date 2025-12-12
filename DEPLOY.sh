#!/usr/bin/env bash
set -euo pipefail

WEB_ROOT="/usr/share/nginx/html"
LOCAL_FILE="index.html"
TARGET_FILE="${WEB_ROOT}/index.html"
WEB_SERVICE="nginx"

###############################################################################
# HELPER FUNCTIONS
###############################################################################

log() {
  printf "[%s] %s\n" "$(date +'%Y-%m-%dT%H:%M:%S')" "$*" >&2
}

fail() {
  log "ERROR: $*"
  exit 1
}

###############################################################################
# PRECHECKS
###############################################################################

check ()
{
    if [ ! -f "${LOCAL_FILE}" ]; then
        fail "The local file is not found in the current directory"
    fi
    if ! command -v sudo > /dev/null; then
        fail "sudo is not available"
    fi
    if ! command -v systemctl > /dev/null; then
        fail "systemctl not available"
    fi
    if [ ! -f "/usr/sbin/${WEB_SERVICE}" ] && [ ! -f "/usr/bin/${WEB_SERVICE}" ]; then
        fail "ngnix is not installed"
    fi
    if [ ! -d "${WEB_ROOT}" ]; then
        fail "The web root '${WEB_ROOT}' doesn't exist!"
    fi

}

###############################################################################
# DEPLOYMENT
###############################################################################

deploy() {
    sudo -v
    check
    log "Starting deployment of '${LOCAL_FILE}' to '${TARGET_FILE}'"

    log "copying the local file to the target file '${LOCAL_FILE}' to '${TARGET_FILE}'"
    if ! sudo cp "${LOCAL_FILE}" "${TARGET_FILE}" > /dev/null; then
        fail "failed to copy the local file '${LOCAL_FILE}' to the web root dir '${WEB_ROOT}'"
        fi
    log "setting permissions for '${TARGET_FILE}'"
    if ! sudo chmod 644 "${TARGET_FILE}"; then
        fail "failed to set permissions"
    fi

    log "restarting the web service '${WEB_SERVICE}'"
    if ! sudo systemctl restart "${WEB_SERVICE}" > /dev/null; then
        fail "failed to restart the web service '${WEB_SERVICE}'"
    fi

    log "deployment finished successfully check http://localhost/"
}

deploy

