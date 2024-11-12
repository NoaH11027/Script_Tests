#!/bin/bash
#
#####
#
# 2024-10-11
# stress-ng ablaufskript
# mlt
#
# 2024-10-30
# Skript aufgebohrt, Funktionalität erweiter
#
#####
#
# base example, never forget the limiter
#
# stress-ng -c 0 -l 75 -t 15
#
#

## ENVIRONMENT ##

timePassed=0
loadPause=5
date=$(date +%Y-%m-%d_%H-%M)
cpu="Core_i5"
cycle=1

## INPUTS ##

  

#i=1
#t=0
#c=15000

## OPTIONS ##



usage () {
	echo 
	echo "Usage: $(basename "$0") <option>"
	echo "  options:"
	echo "	-u, --usage, -h, --help	Show usage message"
	echo "	-cb, --cpubase		cpu base stress pattern"
	echo "	-cm, --cpumatrix	cpu matrix stress pattern for floating point stress"
	echo "	-ci, --cpuinteger	cpu integer method stressor selection stress" 
	echo "	-m, --memory		memory stress test mmap and vm stress "
	echo "	-d, --disk		disk stress, write, read and copy at the physical disk"
	echo "	-r, --random		random stressor"
	echo "	-c, --clean			cleaning logs"
	echo 
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

## MAIN ##

# check for root permissions
[ "$(id -u)" != "0" ] && { 
	echo "root permissions are required to execute the script!" > /dev/stderr; exit 1;
}

case "$1" in
	-h|--help|-u|--usage)
		usage
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
	*)
		echo		
		echo "'$1' is an invalid argument!"
		usage
		exit 2
		;;
esac