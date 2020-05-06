#!/bin/bash


echo "Checking for USB floppy drive..."

while true; do
	fd_log=$(sudo dmesg --nopager | grep -A8 "Y-E DATA ")

	if [ ! -z "$fd_log" ]; then
		fd_name=$(echo $fd_log | head -1 | cut -d\t -f2-3 | awk '{print $2,$3,$4}')
		fd_dev_id=$(sudo dmesg --nopager | grep -Eo "sd[a-z]\:" | tr -d ':')

		echo "$fd_name" > /opt/floppy/etc/fd_name
		echo "$fd_dev_id" > /opt/floppy/etc/fd_dev_id

		printf " Found USB floppy \"%s\" [%s]\n" "$fd_name" "$fd_dev_id"
		fd_disk_id=$(sudo dmesg --nopager | grep -oE "$fd_dev_id[1]")
		echo "$fd_disk_id" > /opt/floppy/etc/fd_disk_id


		if [ ! -z "$fd_disk_id" ]; then
			printf "Mounting /dev/%s -> /media/pi/floppy...\n" "${fd_disk_id}"
			sudo mount -o umask=000 /dev/$fd_disk_id} /media/pi/floppy

		else
			echo "No disk inserted."
		fi

		break
	fi
	sleep 1
done

exit 0

