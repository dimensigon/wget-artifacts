#!/bin/bash

set -eu

TOKEN=`dimensigon token --expire-time 300`

TEMPFILE=`mktemp --suffix=_cloud_init`

cat /home/dimensigon/wget-artifacts/dimensigon/install_and_join.bash > $TEMPFILE

echo "
output 'Cloud-init: Joning to dimension'
su - dimensigon -c \"dimensigon --debug join sqlaas0.dimensigon.com $TOKEN\"

rc=\$?

if [[ \$rc -eq 0 ]]
then
  output 'Cloud-init: Starting dimensigon'
  service dmcore start
else
  echo 'Unable to join to the dimension'
fi
" >> $TEMPFILE

echo "$TEMPFILE"
