#!/bin/bash

#set -eu

#DIMENSIGON="/home/joan/dimensigon/venv3.6/bin/python /home/joan/dimensigon/dimensigon/__main__.py"
DIMENSIGON=dimensigon
SERVER=sqlaas0.dimensigon.com
TOKEN=`$DIMENSIGON token --applicant $1 --expire-time 300`

TEMPFILE=`mktemp --suffix=_cloud_init`

BASEDIR=$(dirname "$0")

cat "$BASEDIR/install_dimensigon.bash" > $TEMPFILE

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
" >> $TEMPFILE

echo "$TEMPFILE"
