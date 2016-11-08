#!/usr/bin/env bash

set -o errexit
set -o errtrace 
set -o nounset
set -o pipefail

################################################
## checks if prerequisites are met and 
## sets up environment variables
function setup_tests { 
  echo "Setting up DC/OS 1.8 Examples Test Suite"
  type dcos >/dev/null 2>&1 || { echo >&2 "I require the DC/OS CLI but it's not installed. Aborting."; exit 1; }
  export MY_CLUSTER_URL=$(dcos config show core.dcos_url)
  export MY_OAUTH_TOKEN=$(dcos config show core.dcos_acs_token)
  # TODO: check if env variables are set (that is, non-empty)
} 

################################################
## shows logs of test case execution 
function display_test_result {
  test_id=$1
  echo "Test [[$test_id]] logs: ================================================="
  dcos task --completed log $(dcos task --completed | grep $test_id | tail -1 | awk '{print $5}')
  dcos task --completed log $(dcos task --completed | grep $test_id | tail -1 | awk '{print $5}') stderr
  echo "========================================================================="
}

################################################
## runs a test: 1. init cluster access, 
## 2. create temporary jobs, and 3. runs the jobs
## 4. cleans up the jobs
function run_test { 
  test_id=$1
  echo "Trying to run [[$test_id]]"
  if [ -f $test_id.json ]; then
    cp $test_id.json $test_id.json.run
    sed -i "" "s#MY_CLUSTER_URL#$MY_CLUSTER_URL#g" $test_id.json.run
    sed -i "" "s/MY_OAUTH_TOKEN/$MY_OAUTH_TOKEN/g" $test_id.json.run
    dcos job add $test_id.json.run
    dcos job run $test_id
    echo "[[$test_id]] submitted"
  else
     echo "[[$test_id]] does not exist, skipping it"
  fi
} 

###############################################################################
## MAIN

setup_tests

for testfile in *.json
do
  testn="${testfile%.*}"
  run_test $testn
done