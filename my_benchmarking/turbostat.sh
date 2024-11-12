#!/bin/bash
#
# 2024-10-11
# turbostat system diagnostic logging
# mlt
#
#
# example:
# turbostat --debug --quiet --show Time_Of_Day_Seconds,TSC_MHz,Bzy_MHz,Core,CPU,C1%c1,C1%,CoreTmp,PkgTmp,PkgWatt,CorWatt,GFXWatt,RAMWatt --out ./logging/turbostat_output.log --interval 2
#

# ENVIRONMENT

date=$(date +%Y-%m-%d)
cpu="Core_i5"

touch ./logging/turbostat_output_"$date"_"$cpu".log
chown vitronic:vitronic ./logging/turbostat_output_"$date"_"$cpu".log 
chmod a+rw ./logging/turbostat_output_"$date"_"$cpu".log

# OPTIONS

usage() {
	echo 
	echo "Usage: $(basename "$0") <option>"
	echo "  options:"
	echo "    -u, --usage, -h, --help		Show usage message"
	echo "    -lv, --logoutverbose		Log output into a logfile, verbose"
	echo "    -sv, --screenoutverbose		Log output onto terminal, verbose"
	echo "    -lc, --logoutcompact		Log output into a logfile, compact"
	echo "    -sc, --screenoutcompact		Log output onto terminal, compact"
	echo 
}

Logging_into_logfile_verbose () {
	echo 	
	echo "verbose turbostat logging will written into logfile"
	echo
	turbostat --debug --quiet --show Time_Of_Day_Seconds,TSC_MHz,Bzy_MHz,Core,CPU,CPU%c1,C1%,CoreTmp,PkgTmp,PkgWatt,CorWatt,GFXWatt,RAMWatt --out ./logging/turbostat_output_"$date"_"$cpu".log --interval 2
}

Logging_onto_terminal_verbose () {
	echo	
	echo "verbose turbostat logging will written into logfile"
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
	echo "compact turbostat logging will written into logfile"
	echo
	turbostat --Summary --quiet --show Time_Of_Day_Seconds,TSC_MHz,Bzy_MHz,CoreTmp,PkgTmp,CorWatt,PkgWatt,GFXWatt --interval 2
}
	 
# MAIN

# check for root permissions
[ "$(id -u)" != "0" ] && { 
	echo "root permissions are required to execute the script!" > /dev/stderr; exit 1;
}

case "$1" in
	-h|--help|-u|--usage)
		usage
		;;
	-lv|--logoutverbose)
		Logging_into_logfile_verbose
		;;
	-sv|--screenoutverbose)
		Logging_onto_terminal_verbose
		;;
	-lc|--logoutcompact)
		Logging_into_logfile_compact
		;;
	-sc|--screenoutcompact)
		Logging_onto_terminal_compact
		;;
	*)
		echo		
		echo "'$1' is an invalid argument!"
		usage
		exit 2
		;;
esac
