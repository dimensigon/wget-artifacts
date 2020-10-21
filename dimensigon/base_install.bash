#!/bin/bash
# Dimensigon - Install Dimensigon Only. Create or Join to be added externally.

set -eu

function dn() { return 0; } #Do Nothing.
function fdt() { date +%Y%m%d%H%M:%S:%N; }
function output() { echo -e "`fdt`:\e[92m$@\e[0m"; }


output "-- Updating & Installing necessary packages --"

useradd -s /bin/bash -m dimensigon

output "-- Installing the necessary packages --"

apt-get update -y

apt-get install -y firewalld python3 python3-wheel python3-dev python3-venv python3-pip libffi-dev libssl-dev autoconf build-essential wget curl

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

su - dimensigon -c "pip install dimensigon"

