#!/bin/bash

DEBUG_MODE=4   #Error (1) <  No Output (2) "Extra INFO" < Output (3) "INFO" < Debug (4)

# Embedded light functions (Power Functions)
function dn() { return 0; } #Do Nothing.
function fdt() { date +%Y%m%d%H%M%S%N; }
function try_delete() { for iii in "$@"; do [ -f $iii ] && rm -f $iii 2>/dev/null || dn; done; }
function root_check() { [ `whoami` = "root" ] || echo -e "\e[33m\e[5mRequires ROOT to run.\e[0m"; }

root_check

#Prep. as Root.

yum -q -y --nogpgcheck install java-1.8.0-openjdk-devel.x86_64 \
libibverbs net-tools ntp gcc gcc-c++ libstdc++-devel compat-libstdc++ libaio libaio.x86_64 libaio-devel \
net-tools kernel-headers kernel-devel perl make systemd tree wget curl bc


curl http://public-yum.oracle.com/public-yum-ol7.repo > /etc/yum.repos.d/public-yum-ol7.repo

yum -q install -y --nogpgcheck oracle-rdbms-server-11gR2-preinstall libibverbs net-tools java-1.8.0-openjdk.x86_64

wget https://raw.githubusercontent.com/danimoya/tctl/master/tctl -O /usr/local/bin/tctl
chmod +x /usr/local/bin/tctl

yum -q clean packages

groupadd -g 500 dba
useradd -g dba tibero

function download_artifact() {

	local SCRIPTS_DIR=~/scripts
	[ -d $SCRIPTS_DIR ] || mkdir $SCRIPTS_DIR
	local GIT_REPO_BASE="https://raw.githubusercontent.com/dimensigon/wget-artifacts/master/"
	wget ${GIT_REPO_BASE}$1 -O $2
	chmod +x $2

}

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
	echo "
	KERNEL==\"sd?\", SUBSYSTEM==\"block\", PROGRAM==\"/lib/udev/scsi_id -g -u -d %N\",
	RESULT==\"$SCSI_ID\", SYMLINK+=\"disk${i}\", OWNER=\"tibero\", GROUP=\"dba\", MODE=\"0600\""
	done

}

format && print_udev_rules > /etc/udev/rules.d/zetadisk.rules

chmod +x /etc/udev/rules.d/zetadisk.rules

udevadm control --reload-rules && udevadm trigger
# ls -l /dev/sd*

# Download Software
wget -q --load-cookies /tmp/cookies.txt \
"https://docs.google.com/uc?export=download&confirm=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate 'https://docs.google.com/uc?export=download&id=1heolAswl3mtao4P1QOWHmdEeDZ1s9QXq' -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')&id=1heolAswl3mtao4P1QOWHmdEeDZ1s9QXq" \
-O /tmp/tibero6-bin-FS06_CS_1902-linux64-175823-opt-20200411042636-tested-zetadata.tar.gz && rm -rf /tmp/cookies.txt
chmod 755 /tmp/tibero6-bin-FS06_CS_1902-linux64-175823-opt-20200411042636-tested-zetadata.tar.gz

wget -q https://raw.githubusercontent.com/dimensigon/tibero-docker/master/bash_profile_tibero -O /home/tibero/.bash_profile
chown tibero:dba /home/tibero/.bash_profile
chmod 740 /home/tibero/.bash_profile

sed -i 's/\(SELINUX=\).*/\1disabled/' /etc/selinux/config 2>/dev/null


function sysctl_set() {

sed -i "/$1/d" /etc/sysctl.conf
echo "$1 = $2" >> /etc/sysctl.conf

}

echo "#Tibero Zetadata Specific" >> /etc/sysctl.conf

sysctl_set "kernel.sem" "100000 100000 100000 100000"
sysctl_set "kernel.shmmni" "4096"
sysctl_set "kernel.shmall" "65956797"

SET_SHMMAX=`free -bwl | grep "Mem:" | awk '{print $2}'`
PCT_RAM_USED=0.5
TOTAL_RAM_BYTES=`echo "scale=1; $SET_SHMMAX*$PCT_RAM_USED" | bc -l | awk -F'.' '{print $1}'`
echo $TOTAL_RAM_BYTES

sysctl_set "kernel.shmmax" "$TOTAL_RAM_BYTES"
sysctl_set "fs.file-max" "6815744"
sysctl_set	"net.ipv4.ip_local_port_range" "1024 65000"
sysctl_set "net.ipv4.tcp_max_syn_backlog" "8192"
sysctl_set "net.core.rmem_default" "4194304"
sysctl_set "net.core.wmem_default" "262144"
sysctl_set "net.core.rmem_max" "67108864"
sysctl_set "net.core.wmem_max" "67108864"

#Until 20200930
wget -q --load-cookies /tmp/cookies.txt \
"https://docs.google.com/uc?export=download&confirm=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate 'https://docs.google.com/uc?export=download&id=1fI_y3wzQo2ieo2yxqfLxqpgyswr7cskX' -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')&id=1fI_y3wzQo2ieo2yxqfLxqpgyswr7cskX" \
-O /home/tibero/tibero6/license/license.xml && rm -rf /tmp/cookies.txt
chown tibero:dba /home/tibero/tibero6/license/license.xml 

tctl check $TB_HOME

