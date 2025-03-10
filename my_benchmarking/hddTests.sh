#!/bin/bash
#
############################################################
#
# SSD Performance Measurement
#
# 2024-12-25
#
# Mark Lüthke
#
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
#   FUNCTIONS
#
############################################################

usage () {

cat << EOF
 
    Usage: $(basename "${BASH_SOURCE[0]}") [-h] [-u] [-qr] [-qw] [-mr] [-rw] [-dc]

    Test script to measure memory read/write throughput utilizing fio.

    Base options:

    -h, --help
    -u, --usage           Print this help and exit

    System stress options

    -qr, --qdread         Sequential READ test, QD32 big blocks for 30 seconds      
    -qw, --qdwrite        Sequentail WRITE test, QD32 big blocks for 30 seconds
    -mr, --qdmixed        Random 4K READ test, QD1 small blocks for 30 seconds
    -rw, --qdrw           Random 4K READ/WRITE test, QD1 small blocks for 30 seconds
    -dc, --diskcomp       Determination for disk compression, three run test

EOF
# exit
}

qd32_bigblock_read () {
    # Sequential READ speed with big blocks QD32 (this should be near the number you see in the specifications for your drive)
    fio --name TEST --eta-newline=2s --filename=fio-tempfile.dat --rw=read --size=500m --io_size=10g --blocksize=1024k --ioengine=libaio --fsync=10000 --iodepth=32 --direct=1 --numjobs=1 --runtime=60 --time_based --group_reporting --output=./logging/"$date"_fioQD32read_"$cpu".log
    rm fio-tempfile.dat
}

qd32_bigblock_write () {
    # Sequential WRITE speed with big blocks QD32 (this should be near the number you see in the specifications for your drive)
    fio --name TEST --eta-newline=2s --filename=fio-tempfile.dat --rw=write --size=500m --io_size=10g --blocksize=1024k --ioengine=libaio --fsync=10000 --iodepth=32 --direct=1 --numjobs=1 --runtime=60 --time_based --group_reporting --output=./logging/"$date"_fioQD32write_"$cpu".log
    rm fio-tempfile.dat
}
qd1_random4K_read () {
    # Random 4K read QD1 (this is the number that really matters for real world performance unless you know better for sure)
    fio --name TEST --eta-newline=2s --filename=fio-tempfile.dat --rw=randread --size=500m --io_size=10g --blocksize=4k --ioengine=libaio --fsync=1 --iodepth=1 --direct=1 --numjobs=1 --runtime=60 --group_reporting --output=./logging/"$date"_fioQD1random4Kr_"$cpu".log
    rm fio-tempfile.dat
}
qd1_random4K_readwrite () {
    # Mixed random 4K read and write QD1 with sync (this is worst case performance you should ever expect from your drive, usually less than 1% of the numbers listed in the spec sheet)
    fio --name TEST --eta-newline=2s --filename=fio-tempfile.dat --rw=randrw --size=500m --io_size=10g --blocksize=4k --ioengine=libaio --fsync=1 --iodepth=1 --direct=1 --numjobs=1 --runtime=60 --group_reporting --output=./logging/"$date"_fioQD1random4Krw_"$cpu".log
    rm fio-tempfile.dat
}

# Increase the --size argument to increase the file size. Using bigger files may reduce the numbers you get depending on drive technology and firmware. Small files will give "too good" results for rotational media because the read head does not need to move that much. If your device is near empty, using file big enough to almost fill the drive will get you the worst case behavior for each test. In case of SSD, the file size does not matter that much.

#
# However, note that for some storage media the size of the file is not as important as total bytes written during short time period. For example, some SSDs have significantly faster performance with pre-erased blocks or it might have small SLC flash area that's used as write cache and the performance changes once SLC cache is full (e.g. Samsung EVO series which have 20-50 GB SLC cache). As an another example, Seagate SMR HDDs have about 20 GB PMR cache area that has pretty high performance but once it gets full, writing directly to SMR area may cut the performance to 10% from the original. And the only way to see this performance degration is to first write 20+ GB as fast as possible and continue with the real test immediately afterwards. Of course, this all depends on your workload: if your write access is bursty with longish delays that allow the device to clean the internal cache, shorter test sequences will reflect your real world performance better. If you need to do lots of IO, you need to increase both --io_size and --runtime parameters. Note that some media (e.g. most cheap flash devices) will suffer from such testing because the flash chips are poor enough to wear down very quickly. In my opinion, if any device is poor enough not to handle this kind of testing, it should not be used to hold any valueable data in any case. That said, do not repeat big write tests for 1000s of times because all flash cells will have some level of wear with writing.
# In addition, some high quality SSD devices may have even more intelligent wear leveling algorithms where internal SLC cache has enough smarts to replace data in-place if its being re-written while the data is still in SLC cache. For such devices, if the test file is smaller than total SLC cache of the device, the full test always writes to SLC cache only and you get higher performance numbers than the device can support for larger writes. So for such devices, the file size starts to matter again. If you know your actual workload it's best to test with the file sizes that you'll actually see in real life. If you don't know the expected workload, using test file size that fills about 50% of the storage device should result in a good average result for all storage implementations. Of course, for a 50 TB RAID setup, doing a write test with 25 TB test file will take quite some time!
# Note that fio will create the required temporary file on first run. It will be filled with pseudorandom data to avoid getting too good numbers from devices that try to cheat in benchmarks by compressing the data before writing it to permanent storage. The temporary file will be called fio-tempfile.dat in above examples and stored in current working directory. So you should first change to directory that is mounted on the device you want to test. The fio also supports using direct media as the test target but I definitely suggest reading the manual page before trying that because a typo can overwrite your whole operating system when one uses direct storage media access (e.g. accidentally writing to OS device instead of test device).
# If you have a good SSD and want to see even higher numbers, increase --numjobs above. That defines the concurrency for the reads and writes. The above examples all have numjobs set to 1 so the test is about single threaded process reading and writing (possibly with the queue depth or QD set with iodepth). High end SSDs (e.g. Intel Optane 905p) should get high numbers even without increasing numjobs a lot (e.g. 4 should be enough to get the highest spec numbers) but some "Enterprise" SSDs require going to range 32-128 to get the spec numbers because the internal latency of those devices is higher but the overall throughput is insane. Note that increasing numbjobs to high values usually increases the resulting benchmark performance numbers but rarely reflects the real world performance in any way.
# The Intel 905p can do above "Mixed random 4K read and write QD1 with sync" test with following performance:[r=149MiB/s,w=149MiB/s][r=38.2k,w=38.1k IOPS]. If you try that on any other but Optane level hardware, your performance will be A LOT less. Closer to 100 IOPS instead of 38000 IOPS like Optane can do.
#


disk_compression_test () {
    # test for differnces caused by disk compression, eveident on SSDs
    echo disk compression test | tee -a ./logging/"$date"_diskCompressionTest_"$cpu".log
    echo | tee -a ./logging/"$date"_diskCompressionTest_"$cpu".log
    echo without predefined condition | tee -a ./logging/"$date"_diskCompressionTest_"$cpu".log 
    fio --name TEST --eta-newline=1s --rw=randwrite --bs=128k --direct=1 --filename=fio-test-file.dat --size=500m --numjobs=1 --ioengine=libaio --iodepth=32 | grep -A 4 "write:" | tee -a ./logging/"$date"_diskCompressionTest_"$cpu".log
    echo | tee -a ./logging/"$date"_diskCompressionTest_"$cpu".log
    echo with zero buffers | tee -a ./logging/"$date"_diskCompressionTest_"$cpu".log
    echo | tee -a ./logging/"$date"_diskCompressionTest_"$cpu".log
    fio --name TEST --eta-newline=1s --rw=randwrite --bs=128k --direct=1 --filename=fio-test-file.dat --size=500m --numjobs=1 --ioengine=libaio --iodepth=32 --zero_buffers | grep -A 4 "write:" | tee -a ./logging/"$date"_diskCompressionTest_"$cpu".log
    echo | tee -a ./logging/"$date"_diskCompressionTest_"$cpu".log
    echo with refill buffers | tee -a ./logging/"$date"_diskCompressionTest_"$cpu".log
    echo | tee -a ./logging/"$date"_diskCompressionTest_"$cpu".log
    fio --name TEST --eta-newline=1s --rw=randwrite --bs=128k --direct=1 --filename=fio-test-file.dat --size=500m --numjobs=1 --ioengine=libaio --iodepth=32 --refill_buffers | grep -A 4 "write:" | tee -a ./logging/"$date"_diskCompressionTest_"$cpu".log
    echo | tee -a ./logging/"$date"_diskCompressionTest_"$cpu".log
    rm -f fio-test-file.dat
}

#
# Fio verwendet grundsätzlich zufällige Daten. Um den Aufwand der Generierung der zufälligen Daten etwas zu mindern, wird zu Beginn ein Puffer von zufälligen Daten erstellt, auf den während des Tests laufend zurückgegriffen wird. Zumeist sollen sich aber auch diese zufälligen Daten komprimieren lassen.[1]
# Diese Wiederverwendung des Puffers führt bei aktuellen SSDs (z.B. der Intel 520 Series SSDs) tatsächlich dazu, dass der SSD-Controller Daten komprimieren kann. Performance gleicht dann nahezu jener, wenn lauter Nullen als Daten verwendet werden - z.B. mittels Option "--zero_buffers".
# Um diesen SSD Kompressions-Effekt zu umgehen, kann Fio mit "--refill_buffers" angewiesen werden, den Puffer bei jedem IO-Submit neu zu befüllen
#

############################################################
#
#   MAIN
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
    -qr|--qdread)
        qd32_bigblock_read
        # base stress pattern for the main cpu stressor
        ;;
    -qw|--qdwrite)
        qd32_bigblock_write
        # more specific stress pattern, matrix stressor for floating point operations
        ;;
    -mr|--qdmixed)
        qd1_random4K_read
        # more specific stress pattern, integer stressor for integer operations
        ;;
    -rw|--qdrw)
        qd1_random4K_readwrite
        # more specific stress pattern, integer stressor for integer operations
        ;;
    -dc|--diskcompression)
        disk_compression_test
        # disk test to dtermine the compression capabilties of the device
        ;;
    *)
		echo		
		echo "'$1' is an invalid argument!"
		usage
		exit 2
		;;	           	
esac

