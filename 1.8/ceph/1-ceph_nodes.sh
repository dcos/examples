#!/bin/bash
#######################################################################
### CEPH FRAMEWORK (stage 1) - Ceph Nodes configuration
#######################################################################
# Commands to set up a DC/OS node and get it ready to be part of a
# Ceph cluster created and managed with the DC/OS Mesos Ceph Framework.
# The nodes MUST HAVE at least a SEPARATE VOLUME for Ceph to use
# e.g. in Amazon, provide an extra Volume (/dev/xvdb) for Ceph to use.
# Each section of this file can be copied and pasted on a node that will be
# part of the Ceph installation.
########################################################################

# 0
# Prerequisites on the node - CentOS

# 0.0 Root access --  all these are root operations
sudo su    #need to run all this as root

# 1
# Format the extra volume(s), and reset mesos-slave to pick them up

# 1.1 PARAMETERS to MODIFY if desired to adapt to your installation:
#LIST OF VOLUMES to format as XFS for ceph, SPACE separated as in: 
#"/dev/hda /dev/hdb /dev/hdc"
CEPH_DISKS="/dev/xvdb" 
#just a name for the script below.
CEPH_FDISK=ceph_fdisk_headless.sh 

# 1.2 Format DISKS as XFS
cat > ./$CEPH_FDISK << EOF
#!/bin/sh
hdd="$CEPH_DISKS"
EOF
cat >> ./$CEPH_FDISK << 'EOF'
for i in $hdd;do
echo "n
p
1


w
"|fdisk $i;mkfs.xfs -f $i;done
EOF
chmod +x ./$CEPH_FDISK
./$CEPH_FDISK

# 1.3 loop through the disks/volumes in $CEPH_DISKS, mount them under /dcos/volumeX
WORDS=($CEPH_DISKS)
COUNT=${#WORDS[@]}
for  ((i=0; i<COUNT; i++)); do
  mkdir -p /dcos/volume$i
  #i-th word in string
  DISK=$( echo $CEPH_DISKS | cut -d " " -f $(($i+1)) )
  mount $DISK /dcos/volume$i
done
# check it worked with
mount | grep "/dcos/volume"
# expected output:
# /dev/xvdb on /dcos/volume0 type xfs (rw,relatime,seclabel,attr2,inode64,noquota)

# 1.4 restart mesos-slave to pick up the changes and add the new volumes
systemctl stop dcos-mesos-slave
rm -f /var/lib/dcos/mesos-resources
rm -f /var/lib/mesos/slave/meta/slaves/latest
/opt/mesosphere/bin/make_disk_resources.py /var/lib/dcos/mesos-resources
systemctl start dcos-mesos-slave
# check that the new volumes are visible to Mesos-agent with
cat /var/lib/dcos/mesos-resources | grep volume
# expected output:
# MESOS_RESOURCES='[{"name": "ports", "type": "RANGES", "ranges": {"range": [{"begin": 1025, "end": 2180}, {"begin": 2182, "end": 3887}, {"begin": 3889, "end": 5049}, {"begin": 5052, "end": 8079}, {"begin": 8082, "end": 8180}, {"begin": 8182, "end": 32000}]}}, {"type": "SCALAR", "name": "disk", "role": "*", "disk": {"source": {"type": "MOUNT", "mount": {"root": "/dcos/volume0"}}}, "scalar": {"value": 8049}}, {"type": "SCALAR", "name": "disk", "role": "*", "scalar": {"value": 4031}}]'

# DISKS ARE MOUNTED
# Extra:
systemctl start ntpd #noticed it tends to die and Ceph requires it.
