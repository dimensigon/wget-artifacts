""" Creates a exasol Database in gcloud

usage: create_exasol_db.py [--applicant=APPLICANT] [--port=PORT] [--project-id=ID] [--timeout=SEC] [--preserve-yaml]
                            JOIN_SERVER DEPLOYMENT_NAME

Arguments:
    JOIN_SERVER         Join server to join new instances to dimensigon
    DEPLOYMENT_NAME     Deployment name showed in Deployment Manager

Options:
   --applicant=APPLICANT  Applicant identifier used for join token
   --port=PORT            Port to communicate with [default: 5000]
   --timeout=SEC          Timeout executing gcloud deployment-manager create
   --project-id=ID        Google Project ID to create the deployment
   --preserve-yaml        preserves yaml file without deleting after exit
"""

import os
import subprocess
import sys
import tempfile

import jinja2
from docopt import docopt
from functools import partial

GCLOUD = "gcloud"
# DIMENSIGON = "/home/joan/dimensigon/venv3.6/bin/python /home/joan/dimensigon/dimensigon/__main__.py"
DIMENSIGON = "dimensigon"
print_ = partial(print, end='', flush=True)
dir_path = os.path.dirname(os.path.realpath(__file__))


if __name__ == '__main__':
    argv = docopt(__doc__)

    # Generate TOKEN
    cmd = f"{DIMENSIGON} token"
    if argv['--applicant'] is not None:
        cmd += ' --applicant ' + argv['--applicant']

    cp = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True, timeout=30)
    if cp.returncode == 0:
        token = cp.stdout.decode().strip()
    else:
        if cp.stdout:
            print_(cp.stdout)
        if cp.stderr:
            print_(cp.stderr, file=sys.stderr)
        sys.exit(cp.returncode)

    # Fill JINJA TEMPLATE
    template = jinja2.Template(open(os.path.join(dir_path, 'exasol_cluster_google_generate_new_VNET.yaml.jinja')).read())

    data = dict(TEMPLATE_PATH=dir_path, TOKEN=token, JOIN_SERVER=argv['JOIN_SERVER'])
    if argv['--port'] is not None:
        data.update(PORT=argv['--port'])

    out = template.render(**data)

    yaml_file = tempfile.NamedTemporaryFile(prefix="exasol_db_", suffix=".yaml", mode='w', delete=not argv['--preserve-yaml'])

    yaml_file.write(out)
    yaml_file.flush()

    # Execute DEPLOYMENT
    cmd = GCLOUD
    if argv['--project-id'] is not None:
        cmd += f" --project {argv['--project-id']}"
    cmd += f" deployment-manager deployments create {argv['DEPLOYMENT_NAME']} --config {yaml_file.name}"
    print(cmd)

    cp = subprocess.run(cmd, shell=True, timeout=argv.get('--timeout', None))
    yaml_file.close()  # file will be closed and removed even if the program terminates abruptly
    sys.exit(cp.returncode)
