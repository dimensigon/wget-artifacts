#!/bin/bash
# tibero_lw.bash
# To boot a minimalistic (lightweight) Tibero with minimal resources for economic development.

set -eu

yum clean all
yum repolist
yum -y update

yum -q -y --nogpgcheck install java-1.8.0-openjdk-devel.x86_64 ntp \
	gcc gcc-c++ libgcc libstdc++ libstdc++-devel \
	compat-libstdc++ libaio libaio-devel ufw \
	perl make tree bc wget curl #Extra

#yum -q -y --nogpgcheck install java-1.8.0-openjdk-devel.x86_64 gcc gcc-c++ libgcc libstdc++ libstdc++-devel \
#  libaio libaio-devel libnsl \
#	perl make tree bc wget curl #Extra

yum -q clean packages

sed -i 's/\(SELINUX=\).*/\1disabled/' /etc/selinux/config 2>/dev/null

#function sshd_set() {
#
#sed -i "/^$1/d" /etc/ssh/sshd_config
#echo "$@" >> /etc/ssh/sshd_config
#
#}
#
#sshd_set port 7822

#systemctl restart sshd
#systemctl status sshd

#ufw --force enable
#ufw allow 7822
#ufw allow 8629

function sysctl_set() {

sed -i "/$1/d" /etc/sysctl.conf
echo "$1 = $2" >> /etc/sysctl.conf

}

cp /etc/sysctl.conf /etc/sysctl.conf.before_tibero_install.bkp

echo "#Tibero Specific" >> /etc/sysctl.conf

sysctl_set "kernel.sem" "100000 100000 100000 100000"
sysctl_set "kernel.shmmni" "4096"
sysctl_set "kernel.shmall" "65956797"

SET_SHMMAX=`free -bwl | grep "Mem:" | awk '{print $2}'`
PCT_RAM_USED=0.8
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

sysctl -p

groupadd -g 500 dba
useradd -g dba tibero

useradd -c 'Mostly R/O Account' roaccount
usermod -G dba roaccount
uuidgen |  tr -d "-" > readonly_password
echo "roaccount:`cat readonly_password`" | chpasswd

mkdir /tibero
chown tibero:dba /tibero

wget https://raw.githubusercontent.com/danimoya/tctl/master/tctl -O /usr/local/bin/tctl
chmod +x /usr/local/bin/tctl

# Download Software
wget --progress=dot:mega --load-cookies /tmp/cookies.txt \
"https://docs.google.com/uc?export=download&confirm=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate 'https://docs.google.com/uc?export=download&id=1PdRlSnuH2-e3THVQ2G7_NtiWHrN3B46w' -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')&id=1PdRlSnuH2-e3THVQ2G7_NtiWHrN3B46w" \
-O /tmp/tibero6-bin-FS07_CS_1912-linux64-174424-opt.tar.gz && rm -rf /tmp/cookies.txt
chmod 755 /tmp/tibero6-bin-FS07_CS_1912-linux64-174424-opt.tar.gz

su - tibero -c "wget -q https://raw.githubusercontent.com/dimensigon/wget-artifacts/master/lightweight/tibero/bash_profile_tibero -O /home/tibero/.bash_profile"

#Until 20200930
wget -q --load-cookies /tmp/cookies.txt \
"https://docs.google.com/uc?export=download&confirm=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate 'https://docs.google.com/uc?export=download&id=1mRUj19dZmrqx6lW91QBZn1H7Jn4gglp4' -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')&id=1mRUj19dZmrqx6lW91QBZn1H7Jn4gglp4" \
-O ~/license_dummy.xml && rm -rf /tmp/cookies.txt

su - tibero -c "cd /tibero && tar -xf /tmp/tibero6-*.tar.gz"

rm -f /tmp/tibero6-bin-*.tar.gz

TB_HOME=/tibero/tibero6
chown tibero:dba ~/license_dummy.xml
cp -p ~/license_dummy.xml /tibero/tibero6/license/license.xml

/usr/local/bin/tctl check $TB_HOME

su - tibero -c "wget -q https://raw.githubusercontent.com/dimensigon/wget-artifacts/master/lightweight/tibero/start_4g.bash -O /home/tibero/start_4g.bash"

su - tibero -c "chmod +x start_4g.bash && bash start_4g.bash"

