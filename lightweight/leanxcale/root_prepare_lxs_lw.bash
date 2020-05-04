#!/bin/bash
#LeanXcale Lightweight (LW)
# Min 6G RAM.  (8GB VM)
#Ubuntu #Also supported: RHEL 7 / CentOS

set -eu

function dn() { return 0; } #Do Nothing.
function fdt() { date +%Y%m%d%H%M:%S:%N; }
function output() { echo -e "`fdt`:\e[92m$@\e[0m"; }

SW_NAME=LeanXcale_0.400-SNAPSHOT_latest.tgz

output "-- Updating & Installing necessary packages --"

apt-get update -y

apt-get install -y curl python3-dev libffi-dev libssl-dev \
libxml2-dev openssh-client locate vim tree rsync nux-tools \
libxslt1-dev libjpeg8-dev zlib1g-dev python3-distutils wget gcc screen numactl

output "-- Downloading OpenJDK 1.8 --"

wget https://cdn.azul.com/zulu/bin/zulu8.46.0.19-ca-jdk8.0.252-linux_amd64.deb

apt -y install ./zulu8.46.0.19-ca-jdk8.0.252-linux_amd64.deb

apt -y autoremove

export JAVA_HOME=/usr/lib/jvm/zulu-8-amd64
java -version

output "Downloading LeanXcale Latest Software from GDrive"

#Download LeanXcale latest software.
wget --progress=dot:mega --load-cookies /tmp/cookies.txt \
"https://docs.google.com/uc?export=download&confirm=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate 'https://docs.google.com/uc?export=download&id=1VZYkOkUmZ2k32cf7H0PXYpLi6ow2EPTS' -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')&id=1VZYkOkUmZ2k32cf7H0PXYpLi6ow2EPTS" \
-O /tmp/$SW_NAME && rm -rf /tmp/cookies.txt
chmod 755 /tmp/$SW_NAME

output "-- Adding Users --"

groupadd -g 500 dba
useradd -g dba lxs
mkdir /home/lxs && chown lxs:dba /home/lxs
usermod --shell /bin/bash lxs

useradd -c 'Mostly R/O Account' roaccount
mkdir /home/roaccount && chown roaccount:dba /home/roaccount
usermod -G dba roaccount
usermod --shell /bin/bash roaccount
uuidgen |  tr -d "-" > readonly_password
echo "roaccount:`cat readonly_password`" | chpasswd

output "-- Creating SW Directories --"

export BASEDIR=/lxs/v0_400 #LeanXcale Home.
mkdir -p $BASEDIR
mkdir -p /backup
chown -R lxs:dba /lxs

output "-- Getting PIP3 --"

curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
python3 get-pip.py
#export PATH=$PATH:/usr/local/bin/pip3

su - lxs -c "wget --no-check-certificate https://ca355c55-0ab0-4882-93fa-331bcc4d45bd.pub.cloud.scaleway.com:3000/danimoya/wget-artifacts/raw/master/lightweight/leanxcale/lxs_start.bash -O /home/lxs/lxs_start.bash"
su - lxs -c "chmod +x /home/lxs/lxs_start.bash && ./home/lxs/lxs_start.bash"
