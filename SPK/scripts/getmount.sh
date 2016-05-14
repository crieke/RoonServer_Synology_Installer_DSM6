#!/bin/sh
#Checking for RoonServer share on internal volumes
ROON_SHARE="RoonServer"

VOLS=`ls -d /volume* | sed -n '/USB/!p'`
for i in $VOLS; do
		if [ -d "${i}"/"${ROON_SHARE}" ] ; then
			echo "${i}/${ROON_SHARE}"
			break 1
		fi
done

#Checking for RoonServer Share on external drives
DEVS=`/usr/syno/bin/synousbdisk -enum|grep -v "^Total"`
for i in $DEVS; do
	USB_SHARE_NAME=`/usr/syno/bin/synousbdisk -info $i | grep "Share Name" | awk '{print $3}'`
	if [ "${USB_SHARE_NAME}" == "${ROON_SHARE}" ]; then
		USB_MOUNT=`/usr/syno/bin/synousbdisk -info $i | grep "Mount Path" | awk '{print $3}'`
		echo "${USB_MOUNT}"
	fi
done

