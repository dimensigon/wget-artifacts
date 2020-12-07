#!/bin/bash
# Dimensigon - Install Dimensigon Only

#set -eu

function dn() { return 0; } #Do Nothing.
function fdt() { date +%Y%m%d%H%M:%S:%N; }
function output() { echo -e "`fdt`:\e[92m$@\e[0m"; }

if [ $(command -v setenforce) ]; then
  output "-- SELinux - Disabling SELinux permanently --"
  sed -i 's/^SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
  setenforce 0
fi

output "-- Installing the necessary packages --"

if [ $(command -v apt-get) ]; then
    apt-get update -y
    apt-get install -y firewalld python3 python3-dev python3-venv python3-pip libffi-dev libssl-dev autoconf build-essential
    apt-get install -y xclip
elif [ $(command -v yum) ]; then
    yum -y install python3 python3-devel sqlite-devel openssl-devel xz zlib zlib-devel pcre-devel gcc readline-devel libffi-devel firewalld
    yum -y install xclip
else
    output "No package handling utility found"
    exit 1
fi



output "-- Enabling firewalld & Adding firewall rules --"

systemctl enable firewalld
systemctl start firewalld

firewall-cmd --list-all
firewall-cmd --permanent --add-port=5000/tcp
firewall-cmd --reload
firewall-cmd --list-all

output "-- Creating dimensigon user --"

useradd -s /bin/bash -m dimensigon

echo "Defaults:dimensigon !requiretty
dimensigon    ALL=(ALL)    NOPASSWD:ALL
" >> /etc/sudoers

output "-- Python - Creating a Virtual Environment --"

su - dimensigon -c "python3 -m venv --prompt dimensigon venv"

output "-- Python - Autoload at login time --"

su - dimensigon -c "echo 'source ~/venv/bin/activate' >> .bash_profile"

output "-- PIP Install Dimensigon --"

su - dimensigon -c "pip install --upgrade pip"
su - dimensigon -c "pip install wheel"
su - dimensigon -c "pip install --index-url https://test.pypi.org/simple/ --extra-index-url https://pypi.org/simple dimensigon"
#su - dimensigon -c "pip install dimensigon"

#set +eu

output "-- Installing Dimensigon service --"

function install_service() {

echo "
#!/bin/bash
# Copyright 2012-. KnowTrade Sarl (Dimensigon)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Location: /etc/systemd/system/dimensigon.service

[Unit]
Description=Dimensigon
After=network.target

[Service]
Type=simple
User=dimensigon
Group=dimensigon
ExecStart=/home/dimensigon/venv/bin/dimensigon

[Install]
WantedBy=multi-user.target
" > /etc/systemd/system/dimensigon.service

systemctl enable dimensigon.service

}



[ -f /bin/systemctl ] && install_service

#set -eu

