The following instruction will install Cassandra service on DC/OS cluster backed by Portworx volumes for persistent storage.


# Prerequisites

- A DC/OS v1.9 cluster with Portworx installed on at least 3 private agents.
- Portworx works best when installed on all nodes in a DC/OS cluster. If Portworx is to be installed on a subset of the cluster, then constraints must be used to specify the nodes where Portworx is installed.
- A node in the cluster with a working DC/OS CLI.

Please review the main [Portworx on DCOS](https://docs.portworx.com/scheduler/mesosphere-dcos/) documentation.

# Install Cassandra

portworx-cassandra package should be available under Universe->Packages
![Cassandra Package List](img/Cassandra-install-01.png)
## Default Install
If you want to use the defaults, you can now run the dcos command to install the service
```
 $ dcos package install --yes portworx-cassandra
 ```
You can also click on the  “Install” button on the WebUI next to the service and then click “Install Package”.
This will install all the prerequisites and start a 3 node Cassandra cluster.

## Advanced Install
If you want to modify the defaults, click on the “Install” button next to the package on the DC/OS UI and then click on
“Advanced Installation”
![Cassandra Install Options](img/Cassandra-install-02.png)
This provides an option to change the service name, volume name, volume size, and provide any additional options that needs to be passed to Portworx volume.
Cassandra related parameters can also be modified, for example: number of Cassandra nodes.
![Cassandra Install Options](img/cassandra-install-03.png)
![Cassandra Portworx Options](img/Cassandra-install-04.png)
Click on “Review and Install” and then “Install” to start the installation of the service.
## Install Status
Click on the Services page to monitor the status of the installation.
![Cassandra Service Status](img/Cassandra-service-01.png)
Cassandra cluster is ready to use when the scheduler service and all the Cassandra services are in running state.
![Cassandra Install Complete](img/Cassandra-service-02.png)
Checking the Portworx's cluster will list multiple volumes that were automatically created using the options provided during install.
There will be one volume for each Cassandra node
![Cassandra Portworx Volume](img/Cassandra-volume-01.png)

Install Cassandra CLI using the following command on DC/OS client
```
 $ dcos package install portworx-cassandra --cli
Installing CLI subcommand for package [portworx-cassandra] version [stub-universe]
New command available: dcos portworx-cassandra
```
# Further resource

For more detailed description on using Portworx through DCOS please visit  [Portworx on DCOS framework homepage](https://docs.portworx.com/scheduler/mesosphere-dcos)
