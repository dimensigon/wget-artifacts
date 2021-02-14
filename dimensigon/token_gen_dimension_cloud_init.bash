#!/bin/bash

set -eu

DIMEN=$1
TARGET=$2

TOKEN=`dimensigon token --applicant $TARGET --expire-time 300`

TEMPFILE=`mktemp --suffix=_cloud_init`

#Do the join back to the Dimension
#cat /home/dimensigon/wget-artifacts/lightweight/tibero/tibero_lw_4g_dm.bash > $TEMPFILE

echo "
output 'Cloud-init: Joining to dimension'
su - dimensigon -c \"dimensigon join $DIMEN $TOKEN\"

rc=\$?

if [[ \$rc -eq 0 ]]
then
  output 'Cloud-init: Starting dimensigon'
  su - dimensigon -c \"dimensigon --daemon\"
else
  echo 'Unable to join to the dimension'
fi
" >> $TEMPFILE

echo "$TEMPFILE"
