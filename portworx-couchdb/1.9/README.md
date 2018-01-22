The following instruction will install Couchdb service on DC/OS cluster backed by Portworx volumes for persistent storage.


# Prerequisites

- A DC/OS v1.9 cluster with Portworx installed on at least 3 private agents
- Portworx works best when installed on all nodes in a DC/OS cluster.  If Portworx is to be installed on a subset of the cluster, then constraints must be used to specify the nodes where Portworx is installed.
- A node in the cluster with a working DC/OS CLI.

Please review the main [Portworx on DCOS](https://docs.portworx.com/scheduler/mesosphere-dcos/) documentation.

# Install Couchdb

portworx-couchdb package should be available under Universe->Packages
![Couchdb Package List](img/Couchdb-install-01.png)
## Default Install
If you want to use the defaults, you can now run the dcos command to install the service
```
 $ dcos package install --yes portworx-couchdb
 ```
You can also click on the  “Install” button on the WebUI next to the service and then click “Install Package”.
This will install all the prerequisites and start a 3 node Couchdb cluster.

## Advanced Install
If you want to modify the defaults, click on the “Install” button next to the package on the DC/OS UI and then click on
“Advanced Installation”
![Couchdb Install Options](img/Couchdb-install-02.png)
This provides an option to change the service name, volume name, volume size, and provide any additional options that needs to be passed to Portworx volume.
Couchdb related parameters can also be modified, for example: number of Couchdb nodes.
![Couchdb Install Options](img/Couchdb-install-03.png)
![Couchdb Portworx Options](img/Couchdb-install-04.png)
Click on “Review and Install” and then “Install” to start the installation of the service.
## Install Status
Click on the Services page to monitor the status of the installation.
![Couchdb Service Status](img/Couchdb-service-01.png)
Couchdb cluster is ready to use when the scheduler service and all the Couchdb services are in running state.
![Couchdb Install Complete](img/Couchdb-service-02.png)
Checking the Portworx's cluster will list multiple volumes that were automatically created using the options provided during install.
There will be one volume for each Couchdb node
![Couchdb Portworx Volume](img/Couchdb-volume-01.png)

Install Couchdb CLI using the following command on DC/OS client
```
 $ dcos package install portworx-couchdb --cli
Installing CLI subcommand for package [portworx-couchdb] version [stub-universe]
New command available: dcos portworx-couchdb
```
# Further resource

For more detailed description on using Portworx through DCOS please visit  [Portworx on DCOS framework homepage](https://docs.portworx.com/scheduler/mesosphere-dcos)
