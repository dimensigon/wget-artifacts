#!/bin/bash
# SSVR (SSD Disks)

function find_eligible_disks(){

	find /dev -name "sd*" 2>/dev/null | grep -E '[0-9]' | tr -d 1234567890 | uniq | tr \/ _ > /tmp/list_partitioned_disks

	find /dev -name "sd*" 2>/dev/null | grep -Ev '[0-9]' | uniq | tr \/ _ > /tmp/list_all_disks

	for each_part in `cat /tmp/list_partitioned_disks`
	do
		BASENAME=`basename $each_part`
		sed -i "/$BASENAME/d" "/tmp/list_all_disks"
	done

	cat /tmp/list_all_disks | tr _ \/

}

function format(){

	for i in `find_eligible_disks`
	do
	fdisk ${i} <<EOF
n
p
1


w
EOF
	echo ${i} >> /tmp/list_eligible_disks
	done

}

function print_udev_rules(){

	for i in `cat /tmp/list_eligible_disks`
	do
	# Check SCSI ID and Generate udev rules.
	SCSI_ID=`/usr/lib/udev/scsi_id -g -u -d ${i}`
	SYM_SUFFIX=`basename ${i}`
	echo "
	KERNEL==\"sd?\", SUBSYSTEM==\"block\", PROGRAM==\"/lib/udev/scsi_id -g -u -d %N\", RESULT==\"$SCSI_ID\", SYMLINK+=\"disk${1}${SYM_SUFFIX}\", OWNER=\"tibero\", GROUP=\"dba\", MODE=\"0600\""
	done

}


function main() {

format && print_udev_rules $1 > /etc/udev/rules.d/$1.rules

chmod +x /etc/udev/rules.d/$1.rules

udevadm control --reload-rules && udevadm trigger

ls -l /dev | egrep "disk{1}*|tibero"

}



case $1 in
	tas)
		main $1
	;;
	ssvr)
		main $1
	;;
	*)
		main tas
	;;
esac
