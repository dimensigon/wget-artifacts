#!/bin/bash

set -eu

TOKEN=`dimensigon token --applicant $1 --expire-time 300`

TEMPFILE=`mktemp --suffix=_cloud_init`

cat /home/dimensigon/wget-artifacts/dimensigon/cloud/scaleway/install_dimensigon.bash > $TEMPFILE

echo "
output 'Cloud-init: Joning to dimension'
su - dimensigon -c \"dimensigon join sqlaas0.dimensigon.com $TOKEN\"

rc=\$?

if [[ \$rc -eq 0 ]]
then
  output 'Cloud-init: Starting dimensigon'
  systemctl start dmcore
else
  echo 'Unable to join to the dimension'
fi
" >> $TEMPFILE

echo "$TEMPFILE"
