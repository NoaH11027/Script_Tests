#!/bin/bash
#
############################################################################################################
#
# Memory Performance Measurement
# 
# Variante
#
# 2024-12-25
#
# Mark Lüthke
#
# sysbench needs to be installed
#
############################################################################################################
#
#   ENVIRONMENT & VARIABLES
#
#############################################################################################################

set -Eeuo pipefail
trap cleanup SIGINT SIGTERM ERR EXIT

# shellcheck disable=SC2034
script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

#############################################################################################################
#
#   FUNCTIONS
#
#############################################################################################################

cleanup () {
    trap - SIGINT SIGTERM ERR EXIT
    # script cleanup here
}

setup_colors () {
    if [[ -t 2 ]] && [[ -z "${NO_COLOR-}" ]] && [[ "${TERM-}" != "dumb" ]]; then
        NOFORMAT='\033[0m' RED='\033[0;31m' GREEN='\033[0;32m' ORANGE='\033[0;33m' BLUE='\033[0;34m' PURPLE='\033[0;35m' CYAN='\033[0;36m' YELLOW='\033[1;33m'
    else
        # shellcheck disable=SC2034
        NOFORMAT='' RED='' GREEN='' ORANGE='' BLUE='' PURPLE='' CYAN='' YELLOW=''
    fi
}

msg () {
    echo >&2 -e "${1-}"
}

die () {
    local msg=$1
    local code=${2-1} # default exit status 1
    msg "$msg"
    exit "$code"
}

memory_writing_test () {
    # memory writing test, 1GB blocks, 20GB total size
    sysbench memory --memory-block-size=1G --memory-total-size=20G --memory-oper=write run
}

memory_reading_test () {
    # memory reading test, 1GB blocks, 20GB total size
    sysbench memory --memory-block-size=1G --memory-total-size=20G --memory-oper=read run
}

parse_params() {
    # default values of variables set from params
    #flag=0
    param=''

    while :; do
    case "${1-}" in
        -mr|--memread)
            memory_reading_test
			# memory reading test, 1GB blocks, 20GB total size
            ;;
        -mw|--memwrite)
            memory_writing_test
			# memory writing test, 1GB blocks, 20GB total size
            ;;
        -?*)
            die "Unknown option: $1"
			# fallback for unknown options
            ;;
        *)
            break
            ;;
    esac
        shift
    done

    args=("$@")

    # check required params and arguments
    [[ -z "${param-}" ]] && die "Missing required parameter: param"
    [[ ${#args[@]} -eq 0 ]] && die "Missing script arguments"

    return 0
}            
