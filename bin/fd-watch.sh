#!/bin/bash



dev_title="Y-E_DATA"
mnt_path=/media/pi/floppy


mount_fd() {
	[[ ! -d "$2" ]] && printf "Mount path '%s' not found, aborting..." && exit 1
	printf "Now attatching floppy '%s' onto %s..." "$1" $2 &> /dev/null
	sudo fsck.fat -aw "$1" &> /dev/null
	sudo mount -o umask=000 "$1" $2
	echo
}


printf "Checking USB floppy drive, also for an inserted disk..."

fd_dev_id=$(ls -l /dev/disk/by-id/ | grep "${dev_title}" | grep -v part | awk -F\/ '{print $NF}')
if [ ! -z "$fd_dev_id" ]; then
	printf "\nDrive found at /dev/%s.\n" "$fd_dev_id"

	fd_part_id=$(ls -l /dev/disk/by-id/ | grep "${fd_dev_id}" | grep part | awk -F\/ '{print $NF}')
	if [ ! -z "$fd_part_id" ]; then fd_part_path="/dev/$fd_part_id"
	else fd_part_path="null" ; fi

	disk_ins=$(lsblk --output=name,path,mountpoint --list | grep "${fd_part_id}" | grep "${fd_part_path}")
	disk_mnt=$(sudo cat /proc/mounts | grep "$mnt_path" | awk '{print $1,$2}')

#	printf "fd_dev_id    : [%s]\nfd_part_id   : [%s]\nfd_part_path : [%s]\ndisk_ins     : [%s]\ndisk_mnt     : [%s]\n" "$fd_dev_id" "$fd_part_id" "$fd_part_path" "$disk_ins" "$disk_mnt"
	if [ -z "$disk_ins" ]; then
		printf "Disk ejected. "
		if [ ! -z "$disk_mnt" ]; then
		    if [ ! -z "$fd_path_path" ]; then
			    printf "Removing previous %s mount..." "$fd_part_path"
			    sudo umount $fd_part_path
		    else
			    printf "Mount records up to date."
			 fi
		fi
		echo

	else
		printf "Disk found at %s..." "$fd_part_path"
		dev_uuid=$(printf "%s}" `lsblk --output=name,ptuuid --json | grep -m1 "$fd_dev_id\"" | tr -d ' ' | rev | cut -c2- | rev` | jq .ptuuid | tr -d '"')
		part_uuid=$(lsblk --output=name,ptuuid --json | grep -m1 "$fd_part_id" | jq .ptuuid | tr -d '"')

#		printf "\ndev_uuid  : [%s]\npart_uuid : [%s]\n" "$dev_uuid" "$part_uuid"
		if [[ "$fd_part_id" && "$dev_uuid" != "$part_uuid" ]]; then
			printf " Stale mount, removing outdated %s..." "$fd_part_path"
			if [ ! -z "$disk_mnt" ]; then
				sudo umount $fd_part_path
			fi

			printf " Updating mount for %s..." "$fd_part_path"
			mount_fd $fd_part_path $mnt_path

		else
			if [ -z "$disk_mnt" ]; then
				printf " Mounting new disk %s..." "$fd_part_path"
				mount_fd $fd_part_path $mnt_path

			else
				printf " No changes."
			fi
		fi
		echo
	fi

else
    printf "\nNo Drive drive found.\n"
fi



#-- terminate w/o eror
exit 0;
