#!/bin/bash
# Lightweight version: DEV1-S size. 4G RAM.

set -eu

# Tibero .bash_profile
export TB_SID=tibero
export TB_HOME=/tibero/tibero6
export TB_CONFIG=$TB_HOME/config
export PATH=$PATH:$TB_HOME/bin:$TB_HOME/client/bin
export LD_LIBRARY_PATH=$TB_HOME/lib:$TB_HOME/client/lib

function dn() { return 0; } #Do Nothing.
function fdt() { date +%Y%m%d%H%M:%S:%N; }
function output() { echo -e "`fdt`:\e[92m$@\e[0m"; }

function tibero_tip_set() {

sed -i "/$1/d" $TB_CONFIG/tibero.tip
echo "$1=$2" >> $TB_CONFIG/tibero.tip

}

output "--- Executing TB_CONFIG/gen_tip.sh ---"
$TB_CONFIG/gen_tip.sh

tibero_tip_set "TOTAL_SHM_SIZE" "7000M"
tibero_tip_set "MEMORY_TARGET" "9200M"

output "--- Creating the Database with TB_HOME/bin/tb_create_db.sh ---"
$TB_HOME/bin/tb_create_db.sh

# Dimensigon VAULT
	#Configure WALLET
	#Store tibero sys passwd.
	#Create encrypted tablespace USERS
#

output "--- Securing Tibero SYS user ---"

uuidgen |  tr -d "-" > sys_password

sleep 5

SYS_PWD=`cat sys_password`

tbsql sys/tibero<<EOF
ALTER USER SYS IDENTIFIED BY "$SYS_PWD";
EOF

output "--- Finished ---"