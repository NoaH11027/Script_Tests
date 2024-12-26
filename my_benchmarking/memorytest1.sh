#!/bin/bash
#
############################################################################################################
#
#   Memory Performance Measurement
# 
#   Variant
#
#   2024-12-25
#
#   Mark Lüthke
#
############################################################################################################
#
#   sysbench needs to be installed
#
#   Not fully developed yet
#
############################################################################################################
#
#   ENVIRONMENT & VARIABLES
#
#############################################################################################################



#############################################################################################################
#
#   FUNCTIONS
#
#############################################################################################################

usage () {

cat << EOF
 
    Usage: $(basename "${BASH_SOURCE[0]}") [-h] [-v] [-f] -p param_value arg1 [arg2...]

    Script description here.

    Base options:

    -h, --help
    -u, --usage             Print this help and exit
    -v, --verbose           Print script debug info

    System stress options

    -cb, --cpubase          CPU stress, basic stressors      
    -cm, --cpumatrix        CPU stress, matrix stressors
    -ci, --cpuinteger       CPU stress, integer stressors
    -m, --memory            Memory stress, mmap and vm stressors
    -d, --disk              Disk stress, different disk stressors
    -r, --random            System stress, random stressors

    Maintenance options

    -cs, --cleanstress      cleaning stress-ng logs, archiving logs
    -ct, --cleanturbo		cleaning turbostat logs, archiving logs
    -nc, --no-colors        output without colors
    -p, --param             named parameter (not used yet)


    Logging options


EOF
exit
}

setup_colors () {
    if [[ -t 2 ]] && [[ -z "${NO_COLOR-}" ]] && [[ "${TERM-}" != "dumb" ]]; then
        NOFORMAT='\033[0m' RED='\033[0;31m' GREEN='\033[0;32m' ORANGE='\033[0;33m' BLUE='\033[0;34m' PURPLE='\033[0;35m' CYAN='\033[0;36m' YELLOW='\033[1;33m'
    else
        # shellcheck disable=SC2034
        NOFORMAT='' RED='' GREEN='' ORANGE='' BLUE='' PURPLE='' CYAN='' YELLOW=''
    fi
}

memory_writing_test () {
    # memory writing test, 1GB blocks, 20GB total size
    sysbench memory --memory-block-size=1G --memory-total-size=20G --memory-oper=write run
}

memory_reading_test () {
    # memory reading test, 1GB blocks, 20GB total size
    sysbench memory --memory-block-size=1G --memory-total-size=20G --memory-oper=read run
}


case "$1" in
    -mr|--memread)
        memory_reading_test
        # memory reading test, 1GB blocks, 20GB total size
        ;;
    -mw|--memwrite)
        memory_writing_test
        # memory writing test, 1GB blocks, 20GB total size
        ;;
    *)
		echo		
		echo "'$1' is an invalid argument!"
		usage
		exit 2
        # break
		;;
esac
 