# How to use NexCloud with DC/OS

[NexCloud][nexcloud] is the container monitoring and performance management solution specialized in Docker, Apache Mesos, Marathon, DC/OS, Mesosphere, Kubernetes(Soon). In this beta version, it support fundamental function to monitor and analyze container cluster(Mesos, DC/OS, Mesosphere), Container, Agent and basic root cause functionality for event management with on-premise version. At next beta and SaaS version, it will provide more rich functionality for root cause (host monitoring, event management, resource tracing, performance monitor and transaction tasing, etc) soon.

* Estimated time for completion: 2 minutes
* Target audience: Cluster operators and application teams
* Scope: Deploy NexCloud for full-stack monitoring

## Prerequisites

* A running DC/OS 1.10 cluster
* A NexCloud environment (try for free [here][freetrial])
* Collecter component (nexcloud-collector) for collecting Mesos, DC/OS, Marathon metrics
* Buisness component (nexcloud-workflow) for calculating metrics collected by nexcloud-collector
* Each components needs [InfluxDB](https://universe.dcos.io/#/package/influxdb/version/latest), [MySQL](https://universe.dcos.io/#/package/mysql/version/latest), [MySQL-admin](https://universe.dcos.io/#/package/mysql-admin/version/latest), [Redis](https://universe.dcos.io/#/package/redis/version/latest), [Kafka](https://universe.dcos.io/#/package/kafka/version/latest)
* Other necessary prerequites are included in components installation.  


## Install NexCloud

To monitor cluster nodes and applications running in DC/OS simply, deploy nexcloud-collector, nexcloud-workflow and NexCloud by means of the DC/OS package. NexCloud will automatically start monitoring of the nodes and applications.


## Additional resources

The NexCloud DC/OS integration is supported by NexCloud.
In case of issues please consult NexCloud Support.

[nexcloud]: http://www.nexcloud.co.kr/
[freetrial]: https://github.com/nexclouding/NexCloud
