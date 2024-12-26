#!/bin/bash

cpu="$(dmidecode -t 4 | grep "Family:" | awk -F" " '{ printf $2"_"$3 }')"
echo "$cpu"

timeoutdefault="30"
read -rp "Please enter the time period for the test to run in seconds [$timeoutdefault]: " timeout
timeout="${timeout:-$timeoutdefault}"
#timeout "$timeout" dd if=/dev/sda | pv -br | dd of=/dev/null 
echo "$timeout"

dd if=/dev/nvme0n1p2 | pv -br | dd of=/dev/null 

#maxCountDefault="15000"
#read -rp "number oc cycles to complete [$maxCountDefault]:  " maxCount
#maxCount="${maxCount:-$maxCountDefault}"

#loadTimeDefault="25"
#read -rp "time for every cycle to pass (in seconds) [$loadTimeDefault]:  " loadTime 
#loadTime="${loadtime:-$loadTimeDefault}"

#loadDefault="90"
#read -rp "percent load applied to the system (load higher 95 is not recommended remotely) [$loadDefault]:  " load
#load="${load:-$loadDefault}"

#echo "maxCount: $maxCount, loadTime: $loadTime, load: $load"

	maxCountDefault="15000"
	read -rp "number of cycles to complete [$maxCountDefault]:  " maxCount
	maxCount="${maxCount:-$maxCountDefault}"
	loadTimeDefault="25"
	read -rp "time for every cycle to pass (in seconds) [$loadTimeDefault]:  " loadTime 
	loadTime="${loadtime:-$loadTimeDefault}"
	stressorVmDefault="2"
	read -rp "number of vm stressors (relate to processor) [$stressorVmDefault]:  " stressorVm
	stressorVm="${stressorVm:-%stressorVmDefault}"
	numberVmDefault="2"
	read -rp "size of vm stressor in GByte (relate to memory available) [${numberVmDefault}G]:  " numberVm
	numberVm="${numberVm:-$numberVmDefault}"
	stressorMnDefault="2"
	read -rp "number of mmap stressors (relate to processor) [$stressorVmDefault]:  " stressorMm
	stressorMm="${stressorMm:-$stressorMnDefault}"
	numberMnDefault="2"
	read -rp "size of mmap stressor in GByte (realte to memory avaialble) [${numberMnDefault}G]:  " numberMm
	numberMm="${numberMm:-$numberMnDefault}" 
	echo

	echo "maxCount: $maxCount, loadTime: $loadTime, stressorVm: $stressorVm, numberVm: ${numberVm}G, stressorMm: $stressorMm, numberMm: ${numberMm}G"


#OUT_PATH_DEFAULT="/tmp/output.txt"
#read -p "Please enter OUT_PATH [$OUT_PATH_DEFAULT]: " OUT_PATH
#OUT_PATH="${OUT_PATH:-$OUT_PATH_DEFAULT}"

#echo "Input: $IN_PATH Output: $OUT_PATH"
