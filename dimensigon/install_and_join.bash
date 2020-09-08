#!/bin/bash
# Dimensigon - Install Dimensigon Only. Create or Join to be added externally.

set -eu

function dn() { return 0; } #Do Nothing.
function fdt() { date +%Y%m%d%H%M:%S:%N; }
function output() { echo -e "`fdt`:\e[92m$@\e[0m"; }

output "-- Updating & Installing necessary packages --"

useradd -s /bin/bash -m dimensigon

echo "
dimensigon    ALL=(ALL)    NOPASSWD:ALL
" >> /etc/sudoers

output "-- Installing the necessary packages --"

apt-get update -y

apt-get install -y firewalld python3 python3-dev python3-venv python3-pip libffi-dev libssl-dev autoconf build-essential

output "-- Adding firewall rules --"

firewall-cmd --list-all
firewall-cmd --permanent --add-port=5000/tcp
firewall-cmd --reload
firewall-cmd --list-all

output "-- Python - Creating a Virtual Environment --"

su - dimensigon -c "python3 -m venv -- prompt dimensigon venv"

output "-- Python - Autoload at login time --"

su - dimensigon -c "echo 'source ~/venv/bin/activate' >> .bash_profile"

output "-- PIP Install Dimensigon --"

su - dimensigon -c "pip install wheel"
su - dimensigon -c "pip install --index-url https://test.pypi.org/simple/ --extra-index-url https://pypi.org/simple dimensigon"

set +eu

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

# Location: /etc/systemd/system/dmcore.service

[Unit]
Description=Dimensigon - DM Core
After=network.target

[Service]
Type=simple
User=dimensigon
Group=dimensigon
ExecStart=/home/dimensigon/venv/bin/dimensigon
ExecStop=kill -15 \`cat ~/.dimensigon/dimensigon.pid\`

[Install]
WantedBy=multi-user.target
" > /etc/systemd/system/dmcore.service

systemctl enable dmcore.service

}

[ -f /bin/systemctl ] && install_service

set -eu

