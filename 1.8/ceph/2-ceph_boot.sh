#!/bin/bash
#######################################################################
### CEPH FRAMEWORK (stage 2) - Launch the CEPH framework from a node
#######################################################################
# Commands to configure the DC/OS Ceph framework and launch it.
# This should be executed on a node that is part of the same network.
# Can be a bootstrap node or any other node in the cluster that has DC/OS CLI
# Assumes this node is in the same subnet used for Ceph
# Assumes this node uses Mesos-DNS and ping leader.mesos works!!!
# Assumes that the "default gateway" interface will be used for Ceph too
# Each section of this file can be copied and pasted on a node that will
# launch the Ceph framework with the DC/OS CLI
######################################################################

# 0
# Prerequisites
###############

# 0.0
# DC/OS CLI
CLI_DOWNLOAD_URL="https://downloads.dcos.io/binaries/cli/linux/x86-64/dcos-1.8/dcos"
echo -e "** Installing DC/OS CLI..."
curl -fLsS --retry 20 -Y 100000 -y 60 $CLI_DOWNLOAD_URL -o dcos &&
 sudo mv dcos /usr/bin &&
 sudo chmod +x /usr/bin/dcos &&
 dcos config set core.dcos_url https://leader.mesos &&
 dcos config set core.ssl_verify false &&
 dcos
dcos auth login


# 0.1
# Marathon-LB installed and working
# NOTE: This is for OSS DC/OS, or EE DC/OS in "disabled" security mode
dcos package install --yes marathon-lb

# 1
# Get parameters required for the CEPH framework configuration.
# Get the HOST network. Assumes this node is on the same subnet as the Ceph NODES
##########################

# get the default gateway interface. Assumes this is the interface used for Ceph too
default_if=$(ip route list | awk '/^default/ {print $5}')
# Get IP@ and netmask for the interface above
IP_ADDR=$( ifconfig $default_if|grep inet|awk -F ' ' '{print $2}'|sed -n 1p )
NETMASK=$( ifconfig $default_if|grep inet|awk -F ' ' '{print $4}'|sed -n 1p )
# Calculate the network from IP_ADDR and NETMASK above
IFS=. read -r i1 i2 i3 i4 <<< "$IP_ADDR"
IFS=. read -r m1 m2 m3 m4 <<< "$NETMASK"
NETWORK=$( printf "%d.%d.%d.%d\n" "$((i1 & m1))" "$((i2 & m2))" "$((i3 & m3))" "$((i4 & m4))" )
# Functions to convert from bitmap netmask (255.255.0.0) to cdr netmask (/16)
# Assumes there's no "255." after a non-255 byte in the mask
mask2cdr ()
{
local x=${1##*255.}
set -- 0^^^128^192^224^240^248^252^254^ $(( (${#1} - ${#x})*2 )) ${x%%.*}
x=${1%%$3*}
echo $(( $2 + (${#x}/4) ))
}
# Get my CDR Mask from the function above
CDRMASK=$(mask2cdr $NETMASK)
#######
# This is the parameter we need for the Ceph Framework
HOST_NETWORK=$NETWORK"/"$CDRMASK
# check value.
echo $HOST_NETWORK
# expected output:
# 172.31.0.0/20

# 2
# Parameters required for the CEPH framework configuration
# Uses the HOST_NETWORK above. Assumes working DC/OS communnication
# Assumes this node uses Mesos-DNS to resolve leader.mesos
###################################################################
# These values should be ok for most installations.
# Assumes no framework authentication.

MESOS_ROLE="ceph-role"
MESOS_PRINCIPAL="ceph-principal"
MESOS_SECRET=""
PUBLIC_NETWORK=$HOST_NETWORK
CLUSTER_NETWORK=$HOST_NETWORK
ZOOKEEPER="leader.mesos:2181"
API_HOST="0.0.0.0"
MESOS_MASTER="leader.mesos:5050"
#determines the Framework version. Edit as appropriate
DOWNLOAD_URI="https://dl.bintray.com/vivint-smarthome/ceph-on-mesos/ceph-on-mesos-0.2.9.tgz"


# 3
# Generate the Marathon JSON for the Ceph Framework with the values above
#########################################################################

rm -f ./ceph-dcos.json
sudo cat >> ceph-dcos.json << 'EOF'
{
  "id": "/ceph",
  "cmd": "cd /mnt/mesos/sandbox/ceph-on-mesos-*\nbin/ceph-on-mesos --api-port=$PORT0",
EOF
sudo cat >> ceph-dcos.json << EOF
  "cpus": 0.3,
  "mem": 512,
  "disk": 0,
  "instances": 1,
  "env": {
    "MESOS_ROLE": "$MESOS_ROLE",
    "MESOS_PRINCIPAL": "$MESOS_PRINCIPAL",
    "PUBLIC_NETWORK": "$PUBLIC_NETWORK",
    "CLUSTER_NETWORK": "$CLUSTER_NETWORK",
    "ZOOKEEPER": "$ZOOKEEPER",
    "API_HOST": "$API_HOST",
    "MESOS_MASTER": "$MESOS_MASTER"
  },
  "uris": ["$DOWNLOAD_URI"],
  "portDefinitions": [{"protocol": "tcp", "name": "api"}],
  "container": {
    "type": "DOCKER",
    "docker": {
      "image": "mesosphere/marathon:v1.3.3",
      "forcePullImage": false,
      "privileged": false,
      "network": "HOST"
    },
    "volumes": [
      {
        "containerPath": "/dev/random",
        "hostPath": "/dev/urandom",
        "mode": "RO"
      }
    ]
  },
  "healthChecks": [
    {
      "protocol": "TCP",
      "gracePeriodSeconds": 300,
      "intervalSeconds": 60,
      "timeoutSeconds": 20,
      "maxConsecutiveFailures": 3
    }
  ],
  "upgradeStrategy": {
    "minimumHealthCapacity": 0,
    "maximumOverCapacity": 0
  },
  "labels": {
    "MARATHON_SINGLE_INSTANCE_APP": "true",
    "HAPROXY_GROUP": "external",
    "DCOS_SERVICE_NAME": "ceph",
    "DCOS_SERVICE_SCHEME": "http",
    "DCOS_SERVICE_PORT_INDEX": "0",
    "DCOS_PACKAGE_IS_FRAMEWORK": "false"
  },
  "acceptedResourceRoles": [
    "*",
    "slave_public"
  ],
  "portDefinitions": [
    {
      "protocol": "tcp",
      "port": 5000,
      "labels": {
        "VIP_0": "/ceph:5000"
      },
      "name": "ceph"
    }
  ]
}
EOF

# 4
# Launch the Ceph Framework with the JSON above
#########################################################################
dcos marathon app add ./ceph-dcos.json

# check it worked by going to your Marathon-LB admin page
echo -e "** Marathon-LB available at: http://PUBLIC_NODE_IP:9090/haproxy?stats"
# expected output
# there should be an entry for the ceph framework on port 15000
# use that entry to go to the CEPH admin interface at:
echo -e "** Ceph Web UI available at: http://PUBLIC_NODE_IP:15000"
