#!/bin/bash

set -eu

function dn() { return 0; } #Do Nothing.
function fdt() { date +%Y%m%d%H%M:%S:%N; }
function output() { echo -e "`fdt`:\e[92m$@\e[0m"; }

ssh-keygen -b 4096 -t rsa -f ~/.ssh/id_rsa -q -N ""

ssh-agent bash
ssh-add ~/.ssh/id_rsa

output "-- LeanXcale Software (LXS) Install --"

export BASEDIR=/lxs/v0_400 #LeanXcale Home.

SW_NAME=LeanXcale_0.400-SNAPSHOT_latest.tgz

cd $BASEDIR && tar xvf /tmp/$SW_NAME

sed -i "/PyYAML/d" $BASEDIR/LX-BIN/scripts/requirements.txt

pip3 install -r $BASEDIR/LX-BIN/scripts/requirements.txt
ansible --version

export PATH=$PATH:/home/lxs/.local/bin

cd $BASEDIR
source ./env.sh

echo "source ./env.sh" >> ~/.bash_profile

output "-- Getting inventory file from private repo --"

wget --no-check-certificate https://ca355c55-0ab0-4882-93fa-331bcc4d45bd.pub.cloud.scaleway.com:3000/danimoya/wget-artifacts/raw/master/lightweight/leanxcale/inventory \
    -O $BASEDIR/conf/inventory

output "-- Deploying the configuration --"

./admin/deploycluster.sh

output "-- Starting the Database Software --"

./admin/startcluster.sh

# lxConsole 3    	# Show components.
# lxClient  			# SQL CLI.

output "-- Creating DB & DBA User --"

uuidgen |  tr -d "-" > leanxcale_password
PWD_LXS=`cat leanxcale_password`
DB_NAME=leanxcale
DB_USER=lxdba
${BASEDIR}/LX-BIN/bin/lxClient << EOF 
  !connect jdbc:leanxcale://localhost:1529/${DB_NAME} ${DB_USER} ${PWD_LXS}
  !tables
  !quit
EOF

#lxClient<<EOF
#!connect jdbc:leanxcale://localhost:1529/lxs1 lxadm $PWD_LXS
#EOF

# leanxcale_password >> EMAIL.
# readonly_password >> EMAIL.

# qe-driver-0.400-20200403.113453-83.jar

output "-- Finished! --"