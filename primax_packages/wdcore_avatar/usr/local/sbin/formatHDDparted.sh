#!/bin/sh
hdd=`cat /tmp/HDDDevNode`

#################################################
#
#	initial
#
#################################################

if [ $# != 1 ] && [ $# != 2 ]; then
	usage
	exit 1
fi

if [ "$1" != "exfat" ] && [ "$1" != "ntfs" ]; then
	usage
	exit 1
fi

if [ $# == 2 ] && [ "$2" != "llf" ]; then
	usage
	exit 1
fi

FS=$1
LLF=false
if [ $# == 2 ]; then
	LLF=false
fi
#############################################
#
#	function
#
#############################################

format(){
	/usr/local/sbin/stopFUSE.sh
	umount /media/SDcard
	umount /media/AFPSDcard
    HDD=${hdd:5:7}
	size=`cat /sys/block/$HDD/size`
	wipefs -ap $hdd;
	sleep 1
	wipefs -ap ${hdd}1;
	if [ $size -gt 3984588800 ]; then #big then 2T
	     parted $hdd mktable gpt -s
         #use ntfs for 3T default
         FS="ntfs"
	else
	     parted $hdd mktable msdos -s
    fi
	parted $hdd mkpart primary NTFS 0% 100% -s
	sleep 3
	mdev -s
	sleep 5
	case $FS in
		"exfat")
			echo "y
			
			"|mkexfat ${hdd}1 -v:"My Passport";
			;;
		"ntfs")
			#echo "y
			#
			#"|mkntfs ${hdd}1 -v:"My Passport";
            mkfs.ntfs -f ${hdd}1 -L "My Passport";
			;;
	esac
	sleep 3;
	# reboot
}

lower_level_format(){
	dataVolumeDevice=`cat /tmp/HDDDevNode`
	blockSize=104857600
	totalBlocks=`df -B ${blockSize} ${dataVolumeDevice} | grep ${dataVolumeDevice} | awk '{print $2}'`
	#echo $totalBlocks
	onePercentBlocks=`expr ${totalBlocks} / 100`

	blockCount=0
	percentCount=0
	percent=1
	while [ ${blockCount} -lt ${totalBlocks} ]
	do
	#	echo blockCount : ${blockCount}  "."  totalBlocks : ${totalBlocks}
		dd bs=${blockSize} seek=${blockCount} count=1 if=/dev/zero of=`cat /tmp/HDDDevNode` 2> /dev/null
	#	sleep 1
	#	echo percentCount : ${percentCount} "." onePercentBlocks : ${onePercentBlocks}	
		if [ "${percentCount}" -gt "${onePercentBlocks}" ]; then
			percentCount=0
			percent=`expr $percent + 1`
			echo "inprogress $percent" > /tmp/wipe-status
		fi
		blockCount=`expr $blockCount + 1`
		percentCount=`expr $percentCount + 1`
	done
	sync

}

usage(){
	echo "$0 exfat|ntfs [llf]"
}

#############################################
#
#	main
#
#############################################

if [ -f /usr/local/sbin/killService.sh ]; then
	/usr/local/sbin/killService.sh hdd
	sleep 10
	[ "$LLF" == "true" ] && lower_level_format
    echo "inprogress 20" > /tmp/wipe-status
	format
	sleep 5
	echo "inprogress 100" > /tmp/wipe-status
    sleep 5
    echo "complete" > /tmp/wipe-status
    sleep 3
    reboot
fi
exit 0	
