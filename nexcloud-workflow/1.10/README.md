# How to use NexCloud-workflow with DC/OS

[NexCloud-workflow][nexcloud] calculating metrics collected by nexcloud-collector from Kafka and store them in Redis, MySQL, InfluxDB.

* Estimated time for completion: 2 minutes
* Target audience: Cluster operators and application teams
* Scope: Deploy NexCloud-workflow for NexCloud buisness logic.

## Prerequisites

* A running DC/OS 1.10 cluster
* A NexCloud Collector component.
* [InfluxDB](https://universe.dcos.io/#/package/influxdb/version/latest)  
* [MySQL](https://universe.dcos.io/#/package/mysql/version/latest), [Redis](https://universe.dcos.io/#/package/redis/version/latest), [Kafka](https://universe.dcos.io/#/package/kafka/version/latest) are nessary for nexcloud-workflow.
* But, it will exist, if you install the nexcloud-collector


## Install NexCloud-Workflow

To monitor cluster nodes and applications running in DC/OS simply deploy NexCloud OneAgent to agent nodes by means of the DC/OS package. NexCloud will automatically start monitoring of the nodes and applications.


## Additional resources

The NexCloud DC/OS integration is supported by NexCloud.
In case of issues please consult NexCloud Support.

[nexcloud]: http://www.nexcloud.co.kr/
[freetrial]: https://github.com/nexclouding/NexCloud
