The following instruction will install Elasticsearch service on DC/OS cluster backed by Portworx volumes for persistent storage.

# Prerequisites

- A DC/OS v1.9 cluster with Portworx installed on at least 3 private agents.
- Portworx works best when installed on all nodes in a DC/OS cluster. If Portworx is to be installed on a subset of the cluster, then constraints must be used to specify the nodes where Portworx is installed.
- A node in the cluster with a working DC/OS CLI.

Please review the main [Portworx on DCOS](https://docs.portworx.com/scheduler/mesosphere-dcos/) documentation.

# Install Elasticsearch
 elastic-portworx package should be available under Universe->Packages
![Elastic Package List](img/Elastic-install-01.png)
## Default Install
If you want to use the defaults, you can now run the dcos command to install the service
```
 $ dcos package install --yes elastic-portworx
```
You can also click on the “Install” button on the WebUI next to the service and then click “Install Package”.

## Advanced Install
If you want to modify the defaults, click on the “Install” button next to the package on the DC/OS UI and then click on
“Advanced Installation”
![Elastic Install Options](img/elastic-install-02.png)
This provides an option to change the service name, volume name, volume size, and provide any additional options that needs to be passed to portworx volume.
The default number of master_node count is 3 and this is not changeable. The default number of data_nodes count is 2. The default count for ingest_nodes and coordinator_nodes is 1.
![Elastic Portworx Options](img/elastic-install-03.png)
![Elastic Install Options](img/elastic-install-04.png)
Click on “Review and Install” and then “Install” to start the installation of the service.
## Install Status
Click on the Services page to monitor the status of the installation.
![Elastic Service Status](img/elastic-service-01.png)
Elasticsearch service is ready to use when the scheduler service and all the Elastic services are in running state.
![Elastic Install Complete](img/Elastic-service-02.png)
Checking the Portworx's cluster will list multiple volumes that were automatically created using the options provided during install.
![Elastic Portworx Volume](img/elastic_volume_01.png)

## Verifying Instalation
Install Elasticsearch CLI using the following command on DC/OS client
```
  $ dcos package install elastic-portworx --cli
```
Find the Elasticsearch master-http endpoint from DCOS workstation
![Elastic Master Endpoint](img/elastic_endpoints.png)

Connect to the master node and check the cluster status
```
$ dcos node ssh --master-proxy --leader
```
![Elastic Cluster Health](img/elastic_cluster_health.png)

# Further resource
For more detailed description on using Portworx through DCOS please visit  [Portworx on DCOS framework homepage](https://docs.portworx.com/scheduler/mesosphere-dcos)
