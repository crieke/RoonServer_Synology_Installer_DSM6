#!/bin/sh
#Checking for RoonServer share on internal volumes
PACKAGE="RoonServer"
SHARE_CONF_LOC="/usr/syno/etc/share_right.map"
SHARE_CONF=`cat "${SHARE_CONF_LOC}" | awk -F ' *= *' '{ if ($1 ~ /^\[/) section=$1; else if ($1 !~ /^$/) print $1 section "=" $2 }'`

ROON_SHARE="$@"

SHARE_ID=($(echo "${SHARE_CONF}" | egrep 'display[[:space:]]name.*$' | grep "=${ROON_SHARE}$" | cut -d "[" -f2 | cut -d "]" -f1))
#SHARE_PATH=($(echo "${SHARE_CONF}" | egrep 'path=.*$' | cut -d "[" -f2 | cut -d "]" -f1))

counter=0
for i in ${SHARE_ID[@]}
  do
#  echo "i: "$i
  SHARE_PATH=($(echo "${SHARE_CONF}" | grep "path\[$i\]\=" | cut -d "[" -f2 | cut -d "=" -f2))
#  echo $SHARE_PATH
  if [[ ! -d "$SHARE_PATH" ]]; then
     SHARE_ID=( "${SHARE_ID[@]/$i}" )
  else
     ((counter++))
	 #echo "Counter: "$counter
     SHARE_VAL="$SHARE_PATH"
fi
done

#counter=0

## Check for esata drives if no share could be found...
## Their share name can't be renamed. Using the comment field instead.
if [[ $counter -eq 0 ]]; then
   SHARE_ID=($(echo "${SHARE_CONF}" | egrep 'comment.*$' | grep "=${ROON_SHARE}$" | cut -d "[" -f2 | cut -d "]" -f1))
   #echo "${SHARE_ID[@]}"
   for i in ${SHARE_ID[@]}
      do
      #  echo "i: "$i
      SHARE_PATH=($(echo "${SHARE_CONF}" | grep "path\[$i\]\=" | cut -d "[" -f2 | cut -d "=" -f2))
      #echo $SHARE_PATH
      DEVICE_PATH=`df | grep "${SHARE_PATH}" | awk '{print $1}'`
      STORAGE_SERIAL=`hdparm -I $DEVICE_PATH | grep "Serial Number" | awk '{print $3}'`
      if [[ "$STORAGE_SERIAL" == "${i::-3}" ]]; then
      if [[ ! -d "$SHARE_PATH" ]]; then
         SHARE_ID=( "${SHARE_ID[@]/$i}" )
      else
         ((counter++))
         echo "Counter: "$counter
         SHARE_VAL="$SHARE_PATH"
      fi
	  fi
   done

fi

if [[ $counter -eq 1 ]]; then
   echo "${SHARE_VAL}"
fi

#if [[ $counter -gt 1 ]]; then
#   echo "Path to \"$@\" share is not obvious/unique."
#fi
