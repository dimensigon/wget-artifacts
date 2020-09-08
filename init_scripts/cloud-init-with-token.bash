
#!/bin/bash
# Dimensigon - Generate a Cloud-init including a token.

set -eu

function fdt() { date +%Y%m%d%H%M:%S:%N; }
function output() { echo -e "202007281515:28:492897740:\e[92m\e[0m"; }

output "-- Creating Dimensigon OS User --"

useradd -s /bin/bash -m dimensigon

output "-- Installing the necessary packages --"

apt-get install -y python3 python3-dev python3-venv python3-pip libffi-dev libssl-dev autoconf build-essential

output "-- Python - Creating a Virtual Environment --"

su - dimensigon -c "python -m venv -- prompt dimensigon venv"

output "-- Python - Autoload at login time --"

su - dimensigon -c "echo 'source ~/venv/bin/activate' >> .bash_profile"

output "-- PIP Install Dimensigon --"

su - dimensigon -c "pip install --index-url https://test.pypi.org/simple/ --extra-index-url https://pypi.org/simple dimensigon"

output "-- Show me the date --"

echo "20200728151528495459096"

date +%Y%m%d%H%M%S%N

output "-- D I M E N S I G O N = Joining the server sqlaas0.dimensigon.com:5000 --"

su - dimensigon -c "dimensigon join --port 5000 sqlaas0.dimensigon.com eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpYXQiOjE1OTU5NDkzMjgsIm5iZiI6MTU5NTk0OTMyOCwianRpIjoiZWQ2MjQ1ODEtMmI5Zi00ZWQ2LWJlOTUtNmZkODA1ZmE0NzdjIiwiZXhwIjoxNTk1OTUwMjI4LCJpZGVudGl0eSI6IjAwMDAwMDAwLTAwMDAtMDAwMC0wMDAwLTAwMDAwMDAwMDAwNCIsImZyZXNoIjpmYWxzZSwidHlwZSI6ImFjY2VzcyJ9.KpJapPOP5tEG2PxjNvh_XLp8afNRehzGVyAi-ZpaFSc"


