#!/usr/bin/env bash

set -o errexit
set -o errtrace 
set -o nounset
set -o pipefail

## install DC/OS CLI, needed for stuff below
curl -fLsS --retry 20 -Y 100000 -y 60 https://downloads.dcos.io/binaries/cli/linux/x86-64/dcos-1.8/dcos -o dcos && 
 sudo chmod +x dcos && 
 ./dcos config set core.dcos_url $DCOS_URL 
 ./dcos config set core.dcos_acs_token $DCOS_TOKEN

echo Installing NGINX ...
./dcos package install --yes nginx
