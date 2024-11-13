#!/bin/bash
#
#############################################################
#
#    Testskript zur Prfung von PC Plattformen
#    nutzt
#      - sysstat
#      - stress-ng
#      - turbostat
#      - passmark
#
############################################################
#
#
#   Mark Luethke
#   2024-11-13
#
############################################################

#
#   ENVIRONMENT & VARIABLES
##

timePassed=0
loadPause=5
date=$(date +%Y-%m-%d_%H-%M)
cpu="Core_i5"
cycle=1

set -Eeuo pipefail
trap cleanup SIGINT SIGTERM ERR EXIT

# shellcheck disable=SC2034
script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

#
#   FUNCTIONS
##

usage() {
cat << EOF # remove the space between << and EOF, this is due to web plugin issue
 
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

    -c, --clean             cleaning logs, archiving logs
    -nc, --no-colors        output without colors
    -p, --param             named parameter (not used yet)

EOF
exit
}

cleanup() {
    trap - SIGINT SIGTERM ERR EXIT
    # script cleanup here
}

setup_colors() {
    if [[ -t 2 ]] && [[ -z "${NO_COLOR-}" ]] && [[ "${TERM-}" != "dumb" ]]; then
        NOFORMAT='\033[0m' RED='\033[0;31m' GREEN='\033[0;32m' ORANGE='\033[0;33m' BLUE='\033[0;34m' PURPLE='\033[0;35m' CYAN='\033[0;36m' YELLOW='\033[1;33m'
    else
        # shellcheck disable=SC2034
        NOFORMAT='' RED='' GREEN='' ORANGE='' BLUE='' PURPLE='' CYAN='' YELLOW=''
    fi
}

msg() {
    echo >&2 -e "${1-}"
}

die() {
    local msg=$1
    local code=${2-1} # default exit status 1
    msg "$msg"
    exit "$code"
}

cpu_base_stress_pattern () {
	read -rp "number of cycles to complete:  " maxCount;
	read -rp "time for every cycle to pass (in seconds):  " loadTime;
	read -rp "percent load applied to the system (load higher 95 is not recommended remotely):  " load;
	echo
	echo "processing base cpu stress for $maxCount cycle, with $loadTime seconds per cycle, with $load% load and $loadPause seconds pause between the cycles"  
	echo
	while [ $cycle -lt "$maxCount" ];
	do 	stress-ng -c 0 -l "$load" -t "$loadTime" --stdout --thermalstat 2 --vmstat 10 --timestamp --times --verify >> ./logging/stress-ng_basePattern_"$date"_"$cpu".log;
		echo "Schleife:  " $cycle;
		echo "Schleife:  " $cycle >> ./logging/stress-ng_basePattern_"$date"_"$cpu".log;
		echo "Zeit vergangen seit Start:  " $timePassed;
		echo "Zeit vergangen seit Start:  " $timePassed >> ./logging/stress-ng_basePattern_"$date"_"$cpu".log;
		cycle=$(("$cycle"+1));
		timePassed=$(("$timePassed"+"$loadTime"+"$loadPause"));
		sleep $loadPause;
	done
}

cpu_matrix_stressor () {
	read -rp "number of cycles to complete:  " maxCount;
	read -rp "time for every cycle to pass (in seconds):  " loadTime;
	read -rp "load applied to the system (load higher 95 is not recommended:  " load;
	echo
	echo "processing matrix stressor for cpu stress for $maxCount cycle, with $loadTime seconds per cycle, with $load% load and $loadPause seconds pause between the cycles"
	echo
	while [ $cycle -lt "$maxCount" ];
	do 	stress-ng --matrix 0 --matrix-size 64 -l "$load" -t "$loadTime" --stdout --thermalstat 2 --vmstat 10 --timestamp --times --verify >> ./logging/stress-ng_matrixStressor_"$date"_"$cpu".log;
		echo "Schleife:  " $cycle;
		echo "Schleife:  " $cycle >> ./logging/stress-ng_matrixStressor_"$date"_"$cpu".log;
		echo "Zeit vergangen seit Start:  " $timePassed;
		echo "Zeit vergangen seit Start:  " $timePassed >> ./logging/stress-ng_matrixStressor_"$date"_"$cpu".log;	
		cycle=$(("$cycle"+1));
		timePassed=$(("$timePassed"+"$loadTime"+"$loadPause"));
		sleep $loadPause;
	done
}

cpu_int_methods_stressor () {
	read -rp "number of cycles to complete:  " maxCount;
	read -rp "time for every cycle to pass (in seconds):  " loadTime;
	read -rp "load applied to the system (load higher 95 is not recommended:  " load;
	echo "processing several integer stress methods for $maxCount cycle, with $loadTime seconds per cycle, with $load% load and $loadPause seconds pause between the cycles"
	while [ $cycle -lt "$maxCount" ];
	do 	for method in int8 int16 int32 int64 int128;
			do	stress-ng --cpu 0 --cpu-method "$method" -l "$load" -t "$loadTime" --stdout --thermalstat 2 --vmstat 10 --timestamp --metrics-brief --times >> ./logging/stress-ng_integerMethods_"$date"_"$cpu".log;
		done;
	done
}

memory_mmap_stressor  () {
	read -rp "number of cycles to complete:  " maxCount;
	read -rp "time for every cycle to pass (in seconds):  " loadTime;
	read -rp "number of vm stressors (relate to processor):  " stressorVm;
	read -rp "size of vm stressor in GByte (relate to memory available):  " numberVm;
	read -rp "number of mmap stressors (relate to processor):  " stressorMm;
	read -rp "size of mmap stressor in GByte (realte to memory avaialble):  " numberMm; 
	echo
	echo "processing memory stress with $stressorVm vm stressor using ${numberVm} GByte memory and $stressorMm mmap stressor using $numberMm GigyByte for $maxCount cycle, with $loadTime seconds per cycle, with $load percent load and $loadPause seconds pause between the cycles"
	echo
	while [ $cycle -lt "$maxCount" ];
	do 	stress-ng --vm "$stressorVm" --vm-bytes "${numberVm}G" --mmap "$stressorMm" --mmap-bytes "${numberMm}G" --page-in --thermalstat 2 --vmstat 10 --times --timestamp --stdout --verify -t "$loadTime" >> ./logging/stress-ng_memoryStressor_"$date"_"$cpu".log; 
		echo "Schleife:  " $cycle;
		echo "Schleife:  " $cycle >> ./logging/stress-ng_memoryStressor_"$date"_"$cpu".log;
		echo "Zeit vergangen seit Start:  " $timePassed;
		echo "Zeit vergangen seit Start:  " $timePassed >> ./logging/stress-ng_memoryStressor_"$date"_"$cpu".log;	
		cycle=$(("$cycle"+1));
		timePassed=$(("$timePassed"+"$loadTime"+"$loadPause"));
		sleep $loadPause;
	done
}

hdd_base_stressor () {
	read -rp "number of cycles to complete:  " maxCount;
	read -rp "time for every cycle to pass (in seconds):  " loadTime;
	echo
	echo "processing base hdd stressor for hdd stress for $maxCount cycle, with $loadTime seconds per cycle and $loadPause seconds pause between the cycles"
	echo
	while [ $cycle -lt "$maxCount" ];
	do 	stress-ng --hdd 0 -t "$loadTime" --stdout --thermalstat 2 --vmstat 10 --timestamp --times --verify --verify >> ./logging/stress-ng_hddBaseStressor_"$date"_"$cpu".log;
		echo "Schleife:  " $cycle;
		echo "Schleife:  " $cycle >> ./logging/stress-ng_hddBaseStressor_"$date"_"$cpu".log;
		echo "Zeit vergangen seit Start:  " $timePassed;
		echo "Zeit vergangen seit Start:  " $timePassed >> ./logging/stress-ng_hddBaseStressor_"$date"_"$cpu".log;	
		cycle=$(("$cycle"+1));
		timePassed=$(("$timePassed"+"$loadTime"+"$loadPause"));
		sleep $loadPause;
	done
}

random_all_stressor () {
	read -rp "number of cycles to complete:  " maxCount;
	read -rp "time for every cycle to pass (in seconds):  " loadTime;
	read -rp "load applied to the system (load higher 95 is not recommended:  " load;
	echo
	echo "processing random stressor for cpu stress for $maxCount cycle, with $loadTime seconds per cycle, with $load% load and $loadPause seconds pause between the cycles"
	echo
	while [ $cycle -lt "$maxCount" ];
	do 	stress-ng --random 1 -l "$load" -t "$loadTime" --stdout --thermalstat 2 --vmstat 10 --timestamp --times >> ./logging/stress-ng_randomStressor_"$date"_"$cpu".log;
		echo "Schleife:  " $cycle;
		echo "Schleife:  " $cycle >> ./logging/stress-ng_randomStressor_"$date"_"$cpu".log;
		echo "Zeit vergangen seit Start:  " $timePassed;
		echo "Zeit vergangen seit Start:  " $timePassed >> ./logging/stress-ng_randomStressor_"$date"_"$cpu".log;	
		cycle=$(("$cycle"+1));
		timePassed=$(("$timePassed"+"$loadTime"+"$loadPause"));
		sleep $loadPause;
	done
}

clear_logging () {
	echo
	echo "cleaning the logging directory and packing old logs and archiving them "
	echo
	sleep 2;
	mkdir ./logging/archive;
	tar cvjf ./logging/archive/"$date"_log_backup.tar.bz2 ./logging/stress*log;
	rm -f ./logging/stress*log;
}


parse_params() {
    # default values of variables set from params
    flag=0
    param=''

    while :; do
    case "${1-}" in
        -h|--help|-u|--usage)
            usage
            ;;
        -v | --verbose)
            set -x
            ;;
        -cb|--cpubase)
            cpu_base_stress_pattern
            ;;
        -cm|--cpumatrix)
            cpu_matrix_stressor
            ;;
        -ci|--cpuinteger)
            cpu_int_methods_stressor
            ;;	
        -m|--memory)
            memory_mmap_stressor
            ;;
        -d|--disk)
            hdd_base_stressor
            ;;
        -r|--random)
            random_all_stressor
            ;;
        -c|--clean)
            clear_logging
            ;;	
        -nc|--no-color)
            NO_COLOR=1
            ;;
        -p|--param)
            # example named parameter
            param="${2-}"
            shift
            ;;
        -?*)
            die "Unknown option: $1"
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