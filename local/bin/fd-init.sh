#!/bin/bash



dev_title="Y-E_DATA"
info_path=/opt/local/etc
mnt_path=/media/pi/floppy


#-- create var storage
if [ ! -d "$info_path" ]; then
	mkdir -p $info_path

else
	#-- clear out any prev vals
	if [ "`ls -1 ${info_path} | wc -l | cut -f1`" -ne 0 ]; then rm ${info_path}/* ; fi
fi


echo "Checking for USB floppy drive..."

fd_dev=$(ls -l /dev/disk/by-id | grep "$dev_title" | awk '{print substr($0, index($0, $9))}' | awk '{gsub(/\ \-\>\ \..\/../, " /dev", $0); print}' | awk '{printf "%s %s:",$2,$1}' | rev | cut -c2- | rev)

if [ ! -z "$fd_dev" ]; then
	fd_name=$(echo $fd_dev | tr ':' '\n' | head -1 | cut -d\  -f2 | cut -d\- -f2-3 | tr '_' ' ')
	fd_dev_id=$(echo $fd_dev | tr ':' '\n' | head -1 | cut -d\  -f1 | awk -F\/ '{print $NF}')

	echo -e $fd_name > $info_path/fd-name
	echo -e $fd_dev_id > $info_path/fd-dev-id

	printf "Found USB floppy \"%s\" [%s]\n" "$fd_name" "$fd_dev_id"

	fd_disk_path=$(echo $fd_dev | tr ':' '\n' | tail -1 | cut -d\  -f1)
	fd_disk_id=$(echo $fd_disk_path | awk -F\/ '{print $NF}' | grep -E "$fd_dev_id[1]")

	if [ ! -z "$fd_disk_id" ]; then
		echo -e $fd_disk_path > $info_path/fd-disk-path
		echo -e $fd_disk_id > $info_path/fd-disk-id
	fi
fi


#-- terminate w/o eror
exit 0;
