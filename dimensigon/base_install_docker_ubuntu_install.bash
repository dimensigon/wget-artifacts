useradd -s /bin/bash -m dimensigon

apt-get update -y

apt-get install -y firewalld python3 python3-wheel python3-dev python3-venv python3-pip libffi-dev libssl-dev autoconf build-essential \
wget curl telnet iputils-ping iproute2

su - dimensigon -c "python3 -m venv -- prompt dimensigon venv"

su - dimensigon -c "echo 'source ~/venv/bin/activate' >> .bash_profile"

su - dimensigon -c "pip install dimensigon"
