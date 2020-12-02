#!/bin/bash
echo "Deleting tibero and roaccount and dba group"
userdel -r tibero
userdel -r roaccount
groupdel dba

rm -fr /tibero

if [ -f /etc/sysctl.conf.before_tibero_install.bkp ]; then
  echo "restoring sysctl.conf file"
  yes | cp -i /etc/sysctl.conf.before_tibero_install.bkp /etc/sysctl.conf
fi