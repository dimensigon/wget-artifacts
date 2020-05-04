#!/bin/bash

tar -xf /tmp/tibero6-bin-FS06_CS_1902-linux64-175823-opt-20200411042636-tested-zetadata.tar.gz

echo '# ssvr0.tip
INSTANCE_TYPE=SSVR
LISTENER_PORT=9100
CONTROL_FILES="/home/tibero/tibero6/database/ssvr0/c1.ctl"

MAX_SESSION_COUNT=10
TOTAL_SHM_SIZE=2G
MEMORY_TARGET=3G

SSVR_RECV_PORT_START=9110' > $TB_CONFIG/ssvr0.tip


echo "
ssvr0=((INSTANCE=(HOST=192.168.96.16)(PORT=9100)))
tas0=((INSTANCE=(HOST=192.168.96.16)(PORT=9120)))
tac0=((INSTANCE=(HOST=192.168.96.16)(PORT=9150)(DB_NAME=TAC)))
" > $TB_HOME/client/config/tbdsn.tbr

export TB_SID=ssvr0
tbboot nomount
tbsql sys/tibero <<EOF
create storage server;
save credential;
EOF
tbboot mount
tbsql sys/tibero<<EOF
create storage disk SD00 path '/dev/diskb';
create storage disk SD01 path '/dev/diskc';
create storage disk SD02 path '/dev/diskd';
create storage disk SD03 path '/dev/diske';
create storage disk SD04 path '/dev/diskf';
create storage disk SD05 path '/dev/diskg';
create storage disk SD06 path '/dev/diskh';
create storage disk SD07 path '/dev/diski';
select * from v\$ssvr_storage_disk;
create grid disk GD00 storage disk SD00;
create grid disk GD01 storage disk SD01;
create grid disk GD02 storage disk SD02;
create grid disk GD03 storage disk SD03;
create grid disk GD04 storage disk SD04;
create grid disk GD05 storage disk SD05;
create grid disk GD06 storage disk SD06;
create grid disk GD07 storage disk SD07;
select * from v\$ssvr_grid_disk;
EOF
tbdown
tbboot mount