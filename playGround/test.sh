maxCountDefault="15000"
read -rp "number oc cycles to complete [$maxCountDefault]:  " maxCount
maxCount="${maxCount:-$maxCountDefault}"

loadTimeDefault="25"
read -rp "time for every cycle to pass (in seconds) [$loadTimeDefault]:  " loadTime 
loadTime="${loadtime:-$loadTimeDefault}"

loadDefault="90"
read -rp "percent load applied to the system (load higher 95 is not recommended remotely) [$loadDefault]:  " load
load="${load:-$loadDefault}"

echo "maxCount: $maxCount, loadTime: $loadTime, load: $load"

#OUT_PATH_DEFAULT="/tmp/output.txt"
#read -p "Please enter OUT_PATH [$OUT_PATH_DEFAULT]: " OUT_PATH
#OUT_PATH="${OUT_PATH:-$OUT_PATH_DEFAULT}"

#echo "Input: $IN_PATH Output: $OUT_PATH"
