#!/bin/bash
# Starts Tibero database
# usage: start_tibero.bash SIZE [SYS_PASSWORD]
#
# Arguments:
#   SIZE          size of Tibero memory database. Available: 4, 8 or 12.
#   SYS_PASSWORD  Password that will be set for sys user DB. If not provided a random one will be generated

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

# START Input parsing
if [[ $# -lt 1 ]] || [[ $# -gt 2 ]]; then
  echo -e "usage: start_tibero.bash SIZE [SYS_PASSWORD]\n"
  exit 9
else
  if [[ $1 -eq 4 ]]; then
    TOTAL_SHM_SIZE="1800M"
    MEMORY_TARGET="3000M"
  elif [[ $1 -eq 8 ]]; then
    TOTAL_SHM_SIZE="5200M"
    MEMORY_TARGET="6700M"
  elif [[ $1 -eq 12 ]]; then
    TOTAL_SHM_SIZE="7000M"
    MEMORY_TARGET="9200M"
  else
    echo "Invalid memory size '$1'. Choose from 4, 8 or 12"
    exit 9
  fi
fi

if [ -z "$2" ]; then
  SYS_PWD=`uuidgen |  tr -d "-"`
  echo "$SYS_PWD" > sys_password
else
  SYS_PWD=$2
fi

output "--- Executing TB_CONFIG/gen_tip.sh ---"
$TB_CONFIG/gen_tip.sh

tibero_tip_set "TOTAL_SHM_SIZE" $TOTAL_SHM_SIZE
tibero_tip_set "MEMORY_TARGET" $MEMORY_TARGET

output "--- Creating the Database with TB_HOME/bin/tb_create_db.sh ---"
$TB_HOME/bin/tb_create_db.sh

# Dimensigon VAULT
	#Configure WALLET
	#Store tibero sys passwd.
	#Create encrypted tablespace USERS
#

output "--- Securing Tibero SYS user ---"

sleep 5

tbsql sys/tibero<<EOF
ALTER USER SYS IDENTIFIED BY "$SYS_PWD";
EOF

echo "SYS:$SYS_PWD"
output "--- Finished ---"