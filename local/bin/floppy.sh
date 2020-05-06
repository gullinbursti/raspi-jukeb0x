#!/bin/bash



dev_title="Y-E_DATA"
info_path=/opt/floppy/etc
mnt_path=/media/pi/floppy


printf "Checking for USB floppy drive & inserted disk..."

if [ -f "$info_path/fd-dev-id" ]; then
	fd_dev_id=$(cat "$info_path/fd-dev-id")
	fd_part=$(ls -l /dev/disk/by-id | grep "$dev_title" | awk '{print substr($0, index($0, $9))}' | awk '{gsub(/\ \-\>\ \..\/../, " /dev", $0); print}' | awk '{printf "%s %s\n",$2,$1}' | rev | cut -c2- | rev | tail -1)
	fd_part_path=$(echo $fd_part | cut -d\  -f1 | grep -E "[0-9]")
	if [ -z "$fd_part_path" ]; then echo "Drive busy" ; fi
	fd_part_id=$(echo $fd_part_path | awk -F\/ '{print $NF}')
	disk_ins=$(lsblk --output=name,path,mountpoint --list | grep "$fd_part_path")
	disk_mnt=$(sudo cat /proc/mounts | grep "$fd_part_path")
	echo
	#printf "fd_dev_id : [%s]\nfd_part : [%s]\nfd_part_path : [%s]\nfd_part_id : [%s]\ndisk_ins : [%s]\ndisk_mnt : [%s]\n" "$fd_dev_id" "$fd_part" "$fd_part_path" "$fd_part_id" "$disk_ins" "$disk_mnt"
	if [ -z "$disk_ins" ]; then
		printf "Disk ejected. "
		if [ ! -z "$disk_mnt" ]; then
			printf "Removing previous mount..."
			sudo umount $fd_part_path
			echo
		fi

	else
		printf "Disk found."
		dev_uuid=$(printf "%s}" `lsblk --output=name,ptuuid --json | grep -m1 "$fd_dev_id\"" | tr -d ' ' | rev | cut -c2- | rev` | jq .ptuuid | tr -d '"')
		part_uuid=$(lsblk --output=name,ptuuid --json | grep -m1 "$fd_part_id" | jq .ptuuid | tr -d '"')

		#printf "dev_uuid : [%s]\npart_uuid : [%s]\n" "$dev_uuid" "$part_uuid"

		if [[ "$dev_uuid" != "$part_uuid" ]]; then
			printf " Stale mount, removing previous..."
			if [ ! -z "$disk_mnt" ]; then
				sudo umount $fd_part_path
			fi

			printf "\nUpdating mount..."
			sudo mount -o umask=000 $fd_part_path $mnt_path


		else
			if [ -z "$disk_mnt" ]; then
				printf " Mounting new disk..."
				sudo mount -o umask=000 $fd_part_path $mnt_path

			else
				printf " No changes."
			fi
		fi
		echo

	fi
fi





#-- terminate w/o eror
exit 0;
