#!/usr/bin/env bash

set -o errexit
set -o errtrace 
set -o nounset
set -o pipefail


################################################
## checks if prerequisites are met and 
## sets up environment variables
function init { 
  type dcos >/dev/null 2>&1 || { echo >&2 "I require the DC/OS CLI but it's not installed. Aborting."; exit 1; }
  export MY_CLUSTER_URL=$(dcos config show core.dcos_url)
  export MY_OAUTH_TOKEN=$(dcos config show core.dcos_acs_token)
  # TODO: check if env variables are set (that is, non-empty)
}

################################################
## cleans up a test case locally and in 
## the cluster; does nothing if test doesn't exist
function cleanup_test {
  test_id=$1
  if [ -f $test_id.json.run ]; then
    rm $test_id.json.run
    dcos job remove $test_id
  fi
}

###############################################################################
## MAIN

echo "Cleaning up DC/OS 1.8 Examples Test Suite"

init

for testfile in *.json
do
  testn="${testfile%.*}"
  cleanup_test $testn
done