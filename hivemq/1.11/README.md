# HiveMQ

[HiveMQ](https://www.hivemq.com/) is a [MQTT](http://mqtt.org/) broker tailored specifically for enterprises, which find themselves in the emerging age of Machine-to-Machine communication (M2M) and the Internet of Things.
It was built from the ground up with maximum scalability and enterprise-ready security concepts in mind.

**Table of Contents**

- [Quick Start](#quick-start)
- [Features](#features)
- [Operations](#operations)
    - [Connecting Clients](#connecting-clients)
    - [Monitoring Configuration](#monitoring-configuration)
    - [Sidecar Plans](#sidecar-plans)
    - [Transport Encryption](#transport-encryption)

## Features

*   Easy installation
*   Elastic scaling of nodes
*   Replication for high availability
*   Monitoring
*   Single-command installation for rapid provisioning
*   Multiple clusters for multiple tenancy with DC/OS
*   High availability runtime configuration and software updates
*   Automatic reporting of HiveMQ metrics to the DC/OS StatsD collector
*   [HiveMQ Control Center](https://www.hivemq.com/docs/4/control-center/introduction.html) for live analysis and administration

## Quick Start

To start a basic cluster with cluster three nodes:

```bash
$ dcos package install hivemq
```

This command creates a new HiveMQ cluster with the default name `hivemq`. Two clusters cannot share the same name, so installing additional clusters beyond the default cluster requires customizing the `name` at install time for each additional instance.

**Note:** This cluster will not use a license file and therefore will run in evaluation mode.

### Custom Installation

You can customize the hivemq cluster in a variety of ways by specifying a JSON options file. For example, here is a sample JSON options file that customizes the service name, node count and log level of the brokers

```json
{
    "service": {
        "name": "another-cluster"
    },
    "node": {
        "count": 4
    },
    "hivemq": {
        "hivemq_log_level": "DEBUG"
    }
}
```

## Operations

### Connecting Clients

The Mesosphere DC/OS HiveMQ service provides several endpoints for connecting MQTT clients. In the default configuration, WebSocket and TLS listeners are disabled.
You can update the configuration of your service to enable these listeners without any downtime.

#### Endpoints

The Mesosphere DC/OS HiveMQ service exposes endpoints for connecting directly to the listener of each individual node on the DC/OS agent network.
In addition, a layer 4 virtual IP is created for MQTT listeners of any type.

These endpoints are also published as DNS [SRV records](https://en.wikipedia.org/wiki/SRV_record) on Mesos-DNS. This allows you to provide a custom solution for routing and load-balancing.

See [Discovering the DNS names for a service](https://docs.d2iq.com/mesosphere/dcos/1.12/networking/DNS/mesos-dns/service-naming/#discovering-the-dns-names-for-a-service) for detailed information. 

| Listener type  | individual node | VIP |
|----------------|--------------------------------------------------------------------------|------------------------------------------------------|
| MQTT           | \_mqtt.\_\<service-name\>-\<node-index\>._tcp.\<service-name\>.mesos.          | mqtt.\<service-name\>.l4lb.thisdcos.directory          |
| MQTT-TLS       | \_mqtt-tls.\_\<service-name\>-\<node-index\>._tcp.\<service-name\>.mesos.      | mqtt-tls.\<service-name\>.l4lb.thisdcos.directory      |
| WebSocket      | \_websocket.\_\<service-name\>-\<node-index\>._tcp.\<service-name\>.mesos.     | websocket.\<service-name\>.l4lb.thisdcos.directory     |
| WebSocket-TLS  | \_websocket-tls.\_\<service-name\>-\<node-index\>._tcp.\<service-name\>.mesos. | websocket-tls.\<service-name\>.l4lb.thisdcos.directory |

**Note:** For foldered service names, remove the separator from <i>service-name</i> to make it a valid DNS name.

**Note:** You can customize the port of all VIPs in the service configuration except for the default listener.

**Caution:** While our service can provide TLS listeners, it usually makes sense to offload TLS termination to an external loadbalancer to reduce the CPU load on the brokers.


#### Using Edge-LB

You can also use [Edge-LB](https://docs.d2iq.com/mesosphere/dcos/services/edge-lb/) for connecting your MQTT clients to the brokers. After setting up Edge-LB, [create a pool](https://docs.d2iq.com/mesosphere/dcos/services/edge-lb/1.3/tutorials/single-lb/) using the following `hivemq-pool.json`. Customize the frontend port and framework name according to your required configuration.

```json
{
  "apiVersion": "V2",
  "name": "hivemq",
  "count": 1,
  "haproxy": {
    "stats": {
      "bindPort": 9090
    },
    "frontends": [{
      "bindPort": 1883,
      "protocol": "TCP",
      "linkBackend": {
        "defaultBackend": "mqtt"
      }
    }],
    "backends": [{
      "name": "mqtt",
      "protocol": "TCP",
      "services": [{
        "mesos": {
          "frameworkName": "hivemq",
          "taskNamePattern": ".*-node"
        },
        "endpoint": {
          "portName": "mqtt"
        }
      }]
    }]
  }
}
```

This will create a minimal, single instance pool for connecting your clients using a public node.

See [V2 Pool Reference](https://docs.d2iq.com/mesosphere/dcos/services/edge-lb/latest/pool-configuration/v2-reference/) for advanced configuration options.

**Caution:** By default, Edge-LB will only allow 10k concurrent connections. To change this, you will need to use the template commands to dump and update the `maxconn` parameters in the template.

**Caution:** For larger deployments with >50k connections, you should run multiple instances (increase the count of the pool). 

### Monitoring configuration

#### Setting up a monitoring dashboard (Grafana)

1. Follow the steps at [Export DC/OS Metrics to Prometheus](https://docs.d2iq.com/mesosphere/dcos/1.12/metrics/prometheus/) to set up Prometheus and Grafana on your DC/OS cluster.

2. Open Grafana and add the Prometheus data source.

3. Create a new dashboard by importing the [HiveMQ-Prometheus.json](HiveMQ-Prometheus.json) file.

4. Choose your Prometheus data source

5. Open the dashboard

6. (optional) select the HiveMQ deployment you want to monitor using the `service_name` variable

**Note:** If you wish to adjust the metrics resolution / interval, both the HiveMQ service's interval property and the Prometheus service's scrape interval have to be adjusted.


### Sidecar plans

The DC/OS HiveMQ service also provides several sidecar plans, which allow you to modify the configuration of cluster nodes at runtime.

**Caution:** These plans will apply changes to all currently deployed nodes. Newly created nodes will not receive these changes. You can however re-execute the plans with the same parameters after adding nodes if required.

**Note:** If any of these plans fail (e.g. due to invalid parameters), you should stop their execution. See [Operations](#operations)

#### Add license

Sometimes it is necessary to add a new or refreshed license file to your deployment. For this purpose, you can use the `add-license` plan.

This plan requires the parameters `LICENSE` and `LICENSE_NAME` to be defined, where `LICENSE` is your base64 encoded license file and `LICENSE_NAME` is the name of the license file which will be created.

```bash
$ dcos hivemq --name=<service_name> plan start add-license -p LICENSE=$(cat license.lic | base64) -p LICENSE_NAME=new_license
```

HiveMQ will automatically detect the new license file and enable it if it is valid.

#### Add extension

To install an extension, you can use the `add-extension` plan. This plan requires a single parameter `URL` which requires a path to a `.zip` compressed extension folder.

For example, to manually install the File RBAC Extension on each current cluster node, run:

```bash
$ dcos hivemq --name=<service_name> plan start add-extension -p URL=https://www.hivemq.com/releases/extensions/hivemq-file-rbac-extension-4.0.0.zip
```

#### Add or update extension configuration

To configure an extension, you can update or add configuration files using the `add-config`

For example, to manually configure the File RBAC Extension `credentials.xml` on each currently active cluster node, run:

```bash
$ dcos hivemq --name=<service_name> plan start add-config -p PATH=file-rbac-extension/credentials.xml -p FILE_CONTENT=$(cat local-file.xml | base64)
```

#### Enable / disable extension

Extensions can be enabled or disabled at any cluster nodes' runtime as well. To do so, you can use the `enable-extension` or `disable-extension` plans. Both plans require the parameter `EXTENSION` parameter which corresponds to the extension's folder name, e.g.

```bash
$ dcos hivemq --name=<service_name> plan start disable-extension -p EXTENSION=hivemq-file-rbac-extension
```

#### Delete extension

You can also delete extensions using the `delete-extension` plan. This plan requires the sole parameter `EXTENSION` which corresponds to the extension's folder name.

```bash
$ dcos hivemq --name=<service_name> plan start delete-extension -p EXTENSION=hivemq-file-rbac-extension
```

### Transport encryption

#### Set up the service account

[Grant](https://docs.d2iq.com/mesosphere/dcos/1.12/security/ent/perms-management/) the service account the correct permissions.
- In DC/OS 1.10, the required permission is `dcos:superuser full`.
- In DC/OS 1.11 and later, the required permissions are:
```
dcos:secrets:default:/<service name>/* full
dcos:secrets:list:default:/<service name> read
dcos:adminrouter:ops:ca:rw full
dcos:adminrouter:ops:ca:ro full
```
where `<service name>` is the name of the service to be installed.

```
dcos security org users grant ${SERVICE_ACCOUNT} dcos:mesos:master:task:app_id:<service/name> create
dcos security org users grant ${SERVICE_ACCOUNT} dcos:mesos:master:reservation:principal:dev_hdfs create
dcos security org users grant ${SERVICE_ACCOUNT} dcos:mesos:master:volume:principal:dev_hdfs create
```

#### Install the service
Install the DC/OS HiveMQ service including the following options in addition to your own. This example enables only the MQTT-TLS listener (on port 8883 by default).

You can also enable Cluster transport TLS (only when initially deploying), WebSocket TLS and Control Center TLS listeners.

```json
{
    "service": {
        "service_account": "<your service account name>",
        "service_account_secret": "<full path of service secret>",
        "hivemq": {
            "listener_configuration": {
                "mqtt_tls_enabled": true
            }
        }
    }
}
```