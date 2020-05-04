#!/bin/bash
#LeanXcale Lightweight (LW)
# Min 6G RAM.  (8GB VM)
#Ubuntu #Also supported: RHEL 7 / CentOS

set -eu

SW_NAME=LeanXcale_0.400-SNAPSHOT_latest.tgz

apt-get update -y

apt-get install -y curl python3-dev libffi-dev libssl-dev \
libxml2-dev openssh-client locate vim tree rsync nux-tools \
libxslt1-dev libjpeg8-dev zlib1g-dev python3-distutils wget gcc screen numactl

wget https://cdn.azul.com/zulu/bin/zulu8.46.0.19-ca-jdk8.0.252-linux_amd64.deb

apt -y install ./zulu8.46.0.19-ca-jdk8.0.252-linux_amd64.deb

apt -y autoremove

export JAVA_HOME=/usr/lib/jvm/zulu-8-amd64
java -version

#Download LeanXcale latest software.
wget --progress=dot:mega --load-cookies /tmp/cookies.txt \
"https://docs.google.com/uc?export=download&confirm=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate 'https://docs.google.com/uc?export=download&id=1VZYkOkUmZ2k32cf7H0PXYpLi6ow2EPTS' -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')&id=1VZYkOkUmZ2k32cf7H0PXYpLi6ow2EPTS" \
-O /tmp/$SW_NAME && rm -rf /tmp/cookies.txt
chmod 755 /tmp/$SW_NAME

groupadd -g 500 dba
useradd -g dba lxs

useradd -c 'Mostly R/O Account' roaccount
usermod -G dba roaccount
uuidgen |  tr -d "-" > readonly_password
echo "roaccount:`cat readonly_password`" | chpasswd

export BASEDIR=/lxs/v0_400 #LeanXcale Home.
export BACKUPDIR=/backup
mkdir -p $BASEDIR
mkdir -p /backup
chown -R lxs:dba /lxs

curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
python3 get-pip.py

export PATH=$PATH:/usr/local/bin/pip3

sed -i "/PyYAML/d" $BASEDIR/LX-BIN/scripts/requirements.txt

#gcc required for netifaces module.
pip3 install -r $BASEDIR/LX-BIN/scripts/requirements.txt
ansible --version

ssh-keygen -b 4096 -t rsa -f ~/.ssh/id_rsa -q -N ""

ssh-agent bash
ssh-add ~/.ssh/id_rsa

#su - lxs -c "wget lxs_start.bash"
#su - lxs -c "chmod +x lxs_start.bash && bash lxs_start.bash"
