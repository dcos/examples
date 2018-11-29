# How to use NexClipper-Agent with DC/OS

[NexClipper][nexclipper] is a container monitoring and performance management service for Docker, Apache Mesos, Marathon, DC/OS, Mesosphere, Kubernetes. In this beta version, it supports monitoring and analysis of the container cluster (Mesos, DC/OS, Mesosphere, Kubernetes), Container, Agent, event management, resource tracing, performance monitor and basic root cause functionality for event management with SaaS version. Future versions will provide rich functionality for root cause (event management, resource tracing, performance monitor and transaction tasing, etc) soon.

* Estimated time for completion: 5 minutes
* Target audience: Cluster operators and application teams
* Scope: Deploy NexClipper-Agent for [NexClipper][nexclipper]

## Prerequisites

* A running DC/OS 1.10 cluster
* A NexClipper agent key (try for free [here][freetrial])


## Install NexClipper-Agent

To monitor cluster nodes and applications running in DC/OS simply deploy NexCloud OneAgent to agent nodes by means of the DC/OS package. NexCloud will automatically start monitoring of the nodes and applications.



### Installation on DC/OS agent nodes

Go to the DC/OS universe/catalog web UI and search for "NexClipper-Agent". Click the tile and select "Configure" to enter the required parameters for connecting with NexCloud.

Click the tile and select "Configure" to enter the required parameters for connecting with NexClipper-Agent.

1. Get your NexClipper-Agent key Download URL from your [NexClipper][nexclipper] environment

3. Set the agnet key you downloaded

3. Set the number of instances to the number of DC/OS agent nodes


## Additional resources

The NexClipper-Agent is supported by NexCloud.
In case of issues please consult [NexCloud Support][nexclipper].

[nexclipper]: http://www.nexclipper.com/
[freetrial]: https://server.nexclipper.com