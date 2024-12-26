#!/bin/bash
#
############################################################
#
# SSD Performance Measurement
# 
# Variante
#
# 2024-12-26
#
# Mark Lüthke
#
############################################################

############################################################
#
#   ENVIRONMENT & VARIABLES
#
############################################################


date=$(date +%Y-%m-%d_%H-%M)
# formated date utilized in the logging

# cpu="$(lscpu | grep "Model Name" | awk -F" " '{ print $7 }')"
cpu="$(dmidecode -t 4 | grep "Family:" | awk -F" " '{ printf $2"_"$3 }')"
# cpu type determination used in the logging

dir="./logging"
if [[ ! -e $dir ]]; then
    mkdir $dir
elif [[ ! -d $dir ]]; then
    echo "$dir already exists but is not a directory" 1>&2
fi
# check if logging directory exists and create it if not



############################################################
#
# Functions
#
############################################################

usage () {
    echo not implemented yet
}

harddrive_read_test_terminal () {
    timeoutdefault="30"
    read -rp "Please enter the time period for the test to run in seconds [$timeoutdefault]: " timeout
    timeout="${timeout:-$timeoutdefault}"
    timeout "$timeout" dd if=/dev/nvme0n1p2 | pv -br | dd of=/dev/null 
}

harddrive_read_test_log () {
    timeoutdefault="30"
    read -rp "Please enter the time period for the test to run in seconds [$timeoutdefault]: " timeout
    timeout="${timeout:-$timeoutdefault}"
    timeout "$timeout" dd if=/dev/nvme0n1p2 | pv -br | dd of=/dev/null 2>&1 | tee -a ./logging/"$date"_hddReadTest_"$cpu".log
}

############################################################
#
#   Main
#
############################################################

# check for root permissions
[ "$(id -u)" != "0" ] && { 
	echo "root permissions are required to execute the script!" > /dev/stderr; exit 1;
}

case "$1" in
	-h|--help|-u|--usage)
		# howto use thsi script
		usage
		;;
   	-ht|--hdreadterminal)
		# compact output into logfile
		harddrive_read_test_terminal
		;;
    -hl|--hdreadlog)
        # compact output onto terminal
        harddrive_read_test_log
        ;;
    *)
        echo		
        echo "'$1' is an invalid argument!"
        usage
        exit 2
        ;;	    
esac


#
# execute with timeout commando run for a certain time period
# timeout 10s dd if=/dev/sda | pv -br | dd of=/dev/null
#