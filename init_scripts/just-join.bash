#!/bin/bash
# Dimensigon - Generate a Cloud-init to just join the dimension

TOKEN=`dimensigon token`
SERVER=`grep server ~/.dshell | awk -F= '{print $2}'`
#SERVER=`dshell env get SERVER`
PORT=`grep port ~/.dshell | awk -F= '{print $2}'`
#PORT=`dshell env get PORT`

echo "
#!/bin/bash
# Dimensigon - Generate a Cloud-init including a token.

set -eu

function fdt() { date +%Y%m%d%H%M:%S:%N; }
function output() { echo -e \"`fdt`:\e[92m$@\e[0m\"; }

output \"-- Creating Dimensigon OS User --\"

useradd -s /bin/bash -m dimensigon

output \"-- Installing the necessary packages --\"

apt-get install -y python3 python3-dev python3-venv python3-pip libffi-dev libssl-dev autoconf build-essential

output \"-- Python - Creating a Virtual Environment --\"

su - dimensigon -c \"python -m venv -- prompt dimensigon venv\"

output \"-- Python - Autoload at login time --\"

su - dimensigon -c \"echo 'source ~/venv/bin/activate' >> .bash_profile\"

output \"-- PIP Install Dimensigon --\"

su - dimensigon -c \"pip install --index-url https://test.pypi.org/simple/ --extra-index-url https://pypi.org/simple dimensigon\"

output \"-- Show me the date --\"

echo \"`date +%Y%m%d%H%M%S%N`\"

date +%Y%m%d%H%M%S%N

output \"-- D I M E N S I G O N = Joining the server $SERVER:$PORT --\"

su - dimensigon -c \"dimensigon join --port $PORT $SERVER $TOKEN\"

" > cloud-init-with-token.bash




