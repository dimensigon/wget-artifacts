#!/bin/bash
# DM pre-installed. Join only.

DIMENSIGON=dimensigon
SERVER=$DM_JOIN_SERVER
TOKEN=`$DIMENSIGON token --applicant $1 --expire-time 300`
TEMP_FILE=`mktemp --suffix=_cloud_init`
BASEDIR=$(dirname "$0")

#set -eu

echo "
output 'Cloud-init: Joning to dimension'
su - dimensigon -c \"dimensigon join $SERVER $TOKEN\"

rc=\$?

if [[ \$rc -eq 0 ]]
then
	  output 'Cloud-init: Starting dimensigon'
	    systemctl start dimensigon
    else
	      echo 'Unable to join to the dimension'
fi
" >> $TEMP_FILE

echo "$TEMP_FILE"

