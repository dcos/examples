#!/usr/bin/env bash

set -o errexit
set -o errtrace 
set -o nounset
set -o pipefail

## install jq, needed for stuff below
curl -fLsS https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64 -o jq && 
 sudo chmod +x jq

## install DC/OS CLI, needed for stuff below
curl -fLsS --retry 20 -Y 100000 -y 60 https://downloads.dcos.io/binaries/cli/linux/x86-64/dcos-1.8/dcos -o dcos && 
 sudo chmod +x dcos && 
 ./dcos config set core.dcos_url $DCOS_URL 
 ./dcos config set core.dcos_acs_token $DCOS_TOKEN

## globals
MESOS_MASTER=leader.mesos:5050
MARATHON=leader.mesos:8080
NUM_CLUSTER_NODES=`curl -s $MESOS_MASTER/slaves | ./jq '.slaves | length' | tr -d '[[:space:]]'`

echo Deploying Elasticsearch
./dcos task
#sleep 5
