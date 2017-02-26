#!/bin/sh
#
# � 2010 Western Digital Technologies, Inc. All rights reserved.
#

PATH=/sbin:/bin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

#source /usr/local/sbin/data-volume-config_helper.sh 2>/dev/null
source /etc/system.conf

#hdparm -I `cat /tmp/HDDDevNode` | sed -n -e 's/.*Serial Number=\(.*\)/\1/p' | sed -e 's/^[ \t]*//' | awk '{gsub("WD-","",$0); print $0}'

hdparm -I `cat /tmp/HDDDevNode` | sed -n -e 's/.*Serial Number:\(.*\)/\1/p' | sed -e 's/^[ \t]*//' | awk '{gsub("WD-","",$0); print $0}'

#driveList=(`internalDrives`)
#serial_number=`fw_printenv model 2>/dev/null | cut -d '=' -f 2`

#if [ -n "$serial_number" ]; then
#        echo $serial_number
#else
#        if [ "${#driveList[@]}" == "0" ]; then
#                echo "none"
#        else
#                hdparm -i /dev/sda | sed -n -e 's/.*SerialNo=\(.*\)/\1/p' | sed -e 's/^[ \t]*//' | awk '{gsub("WD-","",$0); print $0}'
#        fi
#fi
