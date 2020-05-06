#!/bin/bash
#LeanXcale Lightweight (LW)
# Hello World LeanXcale

export BASEDIR=/lxs/v0_400

source $BASEDIR/env.sh

echo "
!tables
!quit
" > /home/lxs/helloworld.sql

uuidgen |  tr -d "-" > /home/lxs/leanxcale_password
PWD_LXS=`cat /home/lxs/leanxcale_password`
DB_NAME=leanxcale
DB_USER=lxdb

${BASEDIR}/LX-BIN/bin/lxClient -u "jdbc:leanxcale://localhost:1529/${DB_NAME}" -n ${DB_USER} -p ${PWD_LXS} -f /home/lxs/helloworld.sql --outputformat="vertical"
