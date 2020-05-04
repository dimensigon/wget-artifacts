#!/bin/bash

set -eu

function dn() { return 0; } #Do Nothing.
function fdt() { date +%Y%m%d%H%M:%S:%N; }
function output() { echo -e "`fdt`:\e[92m$@\e[0m"; }

export BASEDIR=/lxs/v0_400 #LeanXcale Home.
export BACKUPDIR=/backup

cd $BASEDIR && tar xvf /tmp/$SW_NAME

ssh-keygen -b 4096 -t rsa -f ~/.ssh/id_rsa -q -N ""

ssh-agent bash
ssh-add ~/.ssh/id_rsa

cd $BASEDIR
source ./env.sh

echo "source ./env.sh" >> ~/.bash_profile

#wget inventory.

./admin/deploycluster.sh

./admin/startcluster.sh

# lxConsole 3    	# Show components.
# lxClient  			# SQL CLI.

uuidgen |  tr -d "-" > leanxcale_password
PWD_LXS=`cat leanxcale_password`
#lxClient<<EOF
#!connect jdbc:leanxcale://localhost:1529/lxs1 lxadm $PWD_LXS
#EOF

# leanxcale_password >> EMAIL.
# readonly_password >> EMAIL.

# qe-driver-0.400-20200403.113453-83.jar
