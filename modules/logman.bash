# vi: set ft=sh
#
# This module provides logging helpers.
declare -igr MDF_LOGMAN_DEBUG=10
declare -igr MDF_LOGMAN_INFO=20
declare -igr MDF_LOGMAN_WARN=30
declare -ig MDF_LOGMAN_LEVEL="${MDF_LOGMAN_INFO}"

function __mdf_logman_print () (
    if [ $# -lt 2 ]; then
        echo "[!!] Bad call to LogMan print function"
    fi
    entlevel="$1"
    entprefix="$2"
    shift 2
    if [ "${MDF_LOGMAN_LEVEL}" -le "$entlevel" ]; then
        echo -e "[${entprefix}${entprefix}] $@"
    fi
)

function mdf_prdebug () (
    __mdf_logman_print "${MDF_LOGMAN_DEBUG}" 'D' "$@"
)
function mdf_prinfo () (
    __mdf_logman_print "${MDF_LOGMAN_INFO}" 'I' "$@"
)
function mdf_prwarn () (
    __mdf_logman_print "${MDF_LOGMAN_WARN}" 'W' "$@"
)
