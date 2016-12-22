![DC/OS Logo](https://acomblogimages.blob.core.windows.net/media/Default/Windows-Live-Writer/dcoslogo.png) ![Portworx Logo](https://github.com/portworx/px-dev/blob/master/images/pwx-256.png)

Portworx provides scale-out storage for containers. Portworx storage is delivered as a container that is installed on your servers. Portworx technology:

* Provides data protection and container-granular management.
* Enables companies to run multi-cloud with any scheduler.
* Manages storage that is directly attached to servers, from cloud volumes, or provided by hardware arrays.
* Is radically simple.

Portworx technology is available as PX-Developer and PX-Enterprise.

- Estimated time for completion: 45 minutes
- Target audience: Anyone who wants to deploy a persistent elastic data services solution on DC/OS. 
- This package requires an intermediate/advanced DC/OS skill set.


**Table of Contents**:

- [Prerequisites](#prerequisites)
- [Portworx Node configuration](#px-node-configuration)
- [Install Portworx](#install-px)
  - [Validate installation](#validate-installation)
- [Use Portworx](#use-px)
- [Uninstall](#uninstall)

Please review the main [Portworx on Mesos](http://docs.portworx.com/run-with-mesosphere.html) documentation.

# Prerequisites

- A running DC/OS v1.8 cluster with at least 3 private agents. Portworx-on-Mesos REQUIRES at least 3 nodes for installation.
- All nodes in the cluster that will participate in a Portworx cluster MUST have a separate non-root volume to use.  
- A node in the cluster with a working DC/OS CLI.
- A key/value data store (both **etcd** and **consul** are supported). 

# Portworx Agent-Node configuration

- Portworx can run on Mesos agent nodes that are either on-prem or in the cloud.
- Portworx works best when installed on all nodes in a DC/OS cluster.  If Portworx is to be installed on a subset of the cluster, then:
 * the agent-nodes must include attributes indicating the participate in the Portworx cluster.
 * services that depend on Portworx volumes must specify "constraints" to ensure they are launched on nodes that can access Portworx volumes.
Please review the main [Portworx on Mesos](http://docs.portworx.com/run-with-mesosphere.html) documnentation.

### Launch a key/value data store

Portworx requires an instance of **etcd** or **consul** for cluster meta-data, prior to launching.  Either launch manually or through a Universe package, taking note of the **service address:port**.

# Install Portworx

## Install Portworx from the DC/OS GUI

Log into DC/OS, go to Universe, and select the Portworx package from Universe. Select `Advanced Installation`. These parameters are ***MANDATORY***:

- ***clusterid*** : Name for this cluster. Can be arbitrary string.

- ***kvdb*** : URL for the instance of the key/value store.  Examples include: etcd://etcd.mycompany.com:4001 or consul:http://consul.mycompany.com:8500

- ***storage*** : Name of the storage device to contribute.  Example:  /dev/sdb

- ***mgmtif*** : Name of the network interface to use for Portworx management traffic.  Example:  enp0s3

- ***dataif*** : Name of the network interface to use for Portworx data traffic.  Example:  enp0s3

- ***headers_dir*** : Name of directory for system header files.  For CoreOS, this should be "/lib/modules".  For all other OS's, use the default "/usr/src".

Once the package is configured according to your installation and needs, click on "Review and Install", and finally on "Install".

![Install Portworx: ](img/DCOS_1-2.png)

## Install Portworx from the DC/OS CLI

Log into a terminal where the DC/OS CLI is installed and has connectivity with the cluster. The mandatory parameters referenced above can be passed as options to the DC/OS CLI by creating a `px-options.json` file with the following content (Modify the values as per your own installation/desire) :

```bash
{
  "service": {
    "name": "portworx"
  },
  "portworx": {
    "cpus": 1,
    "mem": 1024
    "properties": {
    "clusterid": "mycluster",
    "storage": "/dev/sdb",
    "kvdb": "etcd://10.1.2.3:4001",
  }
}
```

Create and save the `px-options.json` file, then launch the Portworx DC/OS package with:

```bash
dcos package install --yes --options ./px-options.json portworx
```

## Validate installation

### Validate from GUI

After installation, the package will be running under the `Services` tab:

![Run: Services View](img/DCOS_2-2.png)


### Validate from CLI

After installation, you can check the correct functioning with:

```bash
dcos package list|grep portworx
```

## Use Portworx

### Creating Volumes

### Using Volumes

### Removing Volumes

# Uninstall Portworx

## Uninstall the Portworx package
Finally, to uninstall, just go into the "Universe" tab, into "Installed" and uninstall the service. Alternatively, from the CLI:

```bash
$ dcos package uninstall portworx
```

# Further resources
1. [Portworx doc site ](http://docs.portworx.com)
2. [Portworx on Mesos framework homepage](http://docs.portworx.com/run-with-mesosphere.html)
