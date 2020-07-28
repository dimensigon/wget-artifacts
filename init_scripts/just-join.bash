#!/bin/bash
# Dimensigon - Generate a Cloud-init to just join the dimension

TOKEN=`dimensigon token`
SERVER=`grep server ~/.dshell | awk -F= '{print $2}'`
#SERVER=`dshell env get SERVER`
PORT=`grep port ~/.dshell | awk -F= '{print $2}'`
#PORT=`dshell env get PORT`

echo "
#!/bin/bash

useradd -s /bin/bash -m dimensigon

apt-get install python3 python3-dev python3-venv python3-pip libffi-dev libssl-dev autoconf build-essential

su - dimensigon -c \"python -m venv -- prompt dimensigon venv\"

su - dimensigon -c \"echo 'source ~/venv/bin/activate' >> .bash_profile\"

su - dimensigon -c \"pip install --index-url https://test.pypi.org/simple/ --extra-index-url https://pypi.org/simple dimensigon\"

su - dimensigon -c \"dimensigon join $SERVER $TOKEN\"

" > cloud-init-with-token.bash




