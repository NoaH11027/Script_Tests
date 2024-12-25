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
# cpu="$(lscpu | grep "Model Name" | awk -F" " '{ print $7 }')"
cpu="$(dmidecode -t 4 | grep "Family:" | awk -F" " '{ printf S2"_"S3 }')"
cycle=1

set -Eeuo pipefail
trap cleanup SIGINT SIGTERM ERR EXIT

# shellcheck disable=SC2034
script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

#
#   FUNCTIONS
##

usage() {

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
	maxCountDefault="15000";
	read -rp "number oc cycles to complete [$maxCountDefault]:  " maxCount;
	maxCount="${maxCount:-$maxCountDefault}";
	loadTimeDefault="25";
	read -rp "time for every cycle to pass (in seconds) [$loadTimeDefault]:  " loadTime; 
	loadTime="${loadtime:-$loadTimeDefault}";
	loadDefault="90";
	read -rp "percent load applied to the system (load higher 95 is not recommended remotely) [$loadDefault]:  " load;
	load="${load:-$loadDefault}";
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
	maxCountDefault="15000";
	read -rp "number oc cycles to complete [$maxCountDefault]:  " maxCount;
	maxCount="${maxCount:-$maxCountDefault}";
	loadTimeDefault="25";
	read -rp "time for every cycle to pass (in seconds) [$loadTimeDefault]:  " loadTime; 
	loadTime="${loadtime:-$loadTimeDefault}";
	loadDefault="90";
	read -rp "percent load applied to the system (load higher 95 is not recommended remotely) [$loadDefault]:  " load;
	load="${load:-$loadDefault}";
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
	maxCountDefault="15000";
	read -rp "number oc cycles to complete [$maxCountDefault]:  " maxCount;
	maxCount="${maxCount:-$maxCountDefault}";
	loadTimeDefault="25";
	read -rp "time for every cycle to pass (in seconds) [$loadTimeDefault]:  " loadTime; 
	loadTime="${loadtime:-$loadTimeDefault}";
	loadDefault="90";
	read -rp "percent load applied to the system (load higher 95 is not recommended remotely) [$loadDefault]:  " load;
	load="${load:-$loadDefault}";
	echo
	echo "processing several integer stress methods for $maxCount cycle, with $loadTime seconds per cycle, with $load% load and $loadPause seconds pause between the cycles"
	while [ $cycle -lt "$maxCount" ];
	do 	for method in int8 int16 int32 int64 int128;
			do	stress-ng --cpu 0 --cpu-method "$method" -l "$load" -t "$loadTime" --stdout --thermalstat 2 --vmstat 10 --timestamp --metrics-brief --times >> ./logging/stress-ng_integerMethods_"$date"_"$cpu".log;
			echo "current method cycle is: $method"
		done;
	done
}

memory_mmap_stressor  () {
	maxCountDefault="15000";
	read -rp "number of cycles to complete [$maxCountDefault]:  " maxCount;
	maxCount="${maxCount:-$maxCountDefault}";
	loadTimeDefault="25";
	read -rp "time for every cycle to pass (in seconds) [$loadTimeDefault]:  " loadTime;
	loadTime="${loadtime:-$loadTimeDefault}";
	stressorVmDefault="2";
	read -rp "number of vm stressors (relate to processor) [$stressorVmDefault]:  " stressorVm;
	stressorVm="${stressorVm:-%stressorVmDefault}";
	numberVmDefault="2";
	read -rp "size of vm stressor in GByte (relate to memory available) [${numberVmDefault}G]:  " numberVm;
	numberVm="${numberVm:-$numberVmDefault}";
	stressorMnDefault="2";
	read -rp "number of mmap stressors (relate to processor) [$stressorVmDefault]:  " stressorMm;
	stressorMm="${stressorMm:-$stressorMnDefault}";
	numberMnDefault="2";
	read -rp "size of mmap stressor in GByte (realte to memory avaialble) [${numberMnDefault}G]:  " numberMm;
	numberMm="${numberMm:-$numberMnDefault}";
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
	maxCountDefault="15000";
	read -rp "number oc cycles to complete [$maxCountDefault]:  " maxCount;
	maxCount="${maxCount:-$maxCountDefault}";
	loadTimeDefault="25";
	read -rp "time for every cycle to pass (in seconds) [$loadTimeDefault]:  " loadTime; 
	loadTime="${loadtime:-$loadTimeDefault}";
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
	maxCountDefault="15000";
	read -rp "number oc cycles to complete [$maxCountDefault]:  " maxCount;
	maxCount="${maxCount:-$maxCountDefault}";
	loadTimeDefault="25";
	read -rp "time for every cycle to pass (in seconds) [$loadTimeDefault]:  " loadTime; 
	loadTime="${loadtime:-$loadTimeDefault}";
	loadDefault="90";
	read -rp "percent load applied to the system (load higher 95 is not recommended remotely) [$loadDefault]:  " load;
	load="${load:-$loadDefault}";
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

clear_stress_logging () {
	echo
	echo "cleaning the stress-ng logging and packing old logs and archiving them "
	echo
	sleep 2;
	mkdir ./logging/archive;
	tar cvjf ./logging/archive/"$date"_log_backup.tar.bz2 ./logging/stress*log;
	rm -f ./logging/stress*log;
}

clear_turbo_logging () {
	echo
	echo "cleaning the stress-ng logging and packing old logs and archiving them "
	echo
	sleep 2;
	mkdir ./logging/archive;
	tar cvjf ./logging/archive/"$date"_log_backup.tar.bz2 ./logging/turbostat*log;
	rm -f ./logging/turbostat*log;
}

Logging_into_logfile_verbose () {
	echo 	
	echo "verbose turbostat logging will written into logfile"
	echo
	turbostat --debug --quiet --show Time_Of_Day_Seconds,TSC_MHz,Bzy_MHz,Core,CPU,CPU%c1,C1%,CoreTmp,PkgTmp,PkgWatt,CorWatt,GFXWatt,RAMWatt --out ./logging/turbostat_output_"$date"_"$cpu".log --interval 2
}

Logging_onto_terminal_verbose () {
	echo	
	echo "verbose turbostat logging will written onto terminal"
	echo
	turbostat --debug --quiet --show Time_Of_Day_Seconds,TSC_MHz,Bzy_MHz,Core,CPU,CPU%c1,C1%,CoreTmp,PkgTmp,PkgWatt,CorWatt,GFXWatt,RAMWatt --interval 2
}

Logging_into_logfile_compact () {
	echo
	echo "compact turbostat logging will written into logfile"
	echo
	turbostat --Summary --quiet --show Time_Of_Day_Seconds,TSC_MHz,Bzy_MHz,CoreTmp,PkgTmp,CorWatt,PkgWatt,GFXWatt --out ./logging/turbostat_output_"$date"_"$cpu".log --interval 2
}

Logging_onto_terminal_compact () {
	echo
	echo "compact turbostat logging will written onto terminal"
	echo
	turbostat --Summary --quiet --show Time_Of_Day_Seconds,TSC_MHz,Bzy_MHz,CoreTmp,PkgTmp,CorWatt,PkgWatt,GFXWatt --interval 2
}


parse_params() {
    # default values of variables set from params
    #flag=0
    param=''

    while :; do
    case "${1-}" in
        -h|--help|-u|--usage)
			# howto use thsi script
            usage
            ;;
        -v | --verbose)
			# extend logging output for every function in thius script
            set -x
            ;;
        -cb|--cpubase)
            cpu_base_stress_pattern
			# base stress pattern for the main cpu stressor
            ;;
        -cm|--cpumatrix)
            cpu_matrix_stressor
			# more specific stress pattern, matrix stressor for floating point operations
            ;;
        -ci|--cpuinteger)
            cpu_int_methods_stressor
			# more specific stress pattern, integer stressor for integer operations
            ;;	
        -m|--memory)
            memory_mmap_stressor
			# stress pattern for memory stressor, using mmap and vm stressors
            ;;
        -d|--disk)
            hdd_base_stressor
			# stress pattern for disk stressor, using hdd stressor
            ;;
        -r|--random)
			# stress pattern vor the cpu stressor, using a random stressor set
            random_all_stressor
            ;;
        -cs|--cleanstress)
			# clear the logging directory and archive existing logs for the stress-ng logs 
            clear_stress_logging
            ;;
        -ct|--cleanturbo)
        	clear_turbo_logging
			# clear the logging directory and archive existing logs for the turbostat logs
        	;;
        -nc|--no-color)
			# output without colors
            NO_COLOR=1
            ;;
        -p|--param)
            # example named parameter
            param="${2-}"
            shift
            ;;
        -lv|--logoutverbose)
			# verbose output into logfile
        	Logging_into_logfile_verbose
        	;;
        -sv|--screenoutverbose)
			# verbose output onto terminal
			Logging_onto_terminal_verbose
			;;
		-lc|--logoutcompact)
			# compact output into logfile
			Logging_into_logfile_compact
			;;
		-sc|--screenoutcompact)
			# compact output onto terminal
			Logging_onto_terminal_compact
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
