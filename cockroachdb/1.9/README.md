# CockroachDB Service Guide

## Table of Contents

- [Overview](#overview)
  - [Features](#features)
- [Quick Start](#quick-start)
- [Installing and Customizing](#installing-and-customizing)
  - [Service Settings](#service-settings)
    - [Service Name](#service-name)
  - [Node Settings](#node-settings)
    - [Node Count](#node-count)
    - [CPU](#cpu)
    - [Memory](#memory)
    - [Ports](#ports)
    - [Storage Volumes](#storage-volumes)
    - [Placement Constraints](#placement-constraints)
  - [CockroachDB Settings](#cockroachdb-settings)
- [Uninstalling](#uninstalling)
- [Connecting Clients](#connecting-clients)
  - [Discovering Endpoints](#discovering-endpoints)
  - [Connecting Clients to Endpoints](#connecting-clients-to-endpoints)
- [Managing](#managing)
  - [Updating Configuration](#updating-configuration)
    - [Adding a Node](#adding-a-node)
    - [Resizing a Node](#resizing-a-node)
    - [Updating Placement Constraints](#updating-placement-constraints)
  - [Restarting a Node](#restarting-a-node)
  - [Replacing a Node](#replacing-a-node)
- [Disaster Recovery](#disaster-recovery)
  - [Backup](#backup)
  - [Restore](#restore)
- [Troubleshooting](#troubleshooting)
  - [Accessing Logs](#accessing-logs)
  - [Accessing Metrics](#accessing-metrics)
- [Limitations](#limitations)
  - [Removing a Node](#removing-a-node)
  - [Updating Storage Volumes](#updating-storage-volumes)
  - [Rack-aware Replication](#rack-aware-replication)
  - [Backup Storage](#backup-storage)
  - [Enterprise Backup and Restore](#enterprise-backup-restore)
- [Supported Versions](#supported-versions)

<a name="overview"></a>
# Overview

DC/OS CockroachDB is an automated service that makes it easy to deploy and manage CockroachDB on [DC/OS](https://mesosphere.com/product/).

CockroachDB is a distributed SQL database built on a transactional and
strongly-consistent key-value store. It **scales** horizontally;
**survives** disk, machine, rack, and even datacenter failures with
minimal latency disruption and no manual intervention; supports
**strongly-consistent** ACID transactions; and provides a familiar
**SQL** API for structuring, manipulating, and querying data.

For more details, check out [its website](https://www.cockroachlabs.com/),
[FAQ](https://cockroachlabs.com/docs/frequently-asked-questions.html), or
original [design document](https://github.com/cockroachdb/cockroach#design).

<a name="features"></a>
## Features

- Single command installation for rapid provisioning
- CLI for easy management
- Multiple CockroachDB clusters sharing a single DC/OS cluster for multi-tenancy
- Multiple CockroachDB instances sharing the same hosts for improved utilization
- Placement constraints for fine-grained instance placement
- Vertical and horizontal scaling for managing capacity
- Rolling software and configuration updates for runtime maintainence
- Built-in load balancing for clients inside the DC/OS cluster
- Easy backup and restore of your databases

<a name="quick-start"></a>
# Quick Start

1. Install DC/OS on your cluster. See [the documentation](https://docs.mesosphere.com/latest/administration/installing/) for instructions.

1. If you are using open source DC/OS, install CockroachDB cluster with the following command from the DC/OS CLI. If you are using Enterprise DC/OS, you may need to follow additional instructions. See the Install and Customize section for more information. You can also install CockroachDB from [the DC/OS web interface](https://docs.mesosphere.com/latest/usage/webinterface/).

	```
	dcos package install cockroachdb
	```

1. The service will now deploy with a default configuration. You can monitor its deployment from the Services tab of the DC/OS web interface.

1. Connect a client to CockroachDB.

	```
	$ dcos cockroachdb endpoints
	[
	  "http",
	  "pg",
	]
	$ dcos cockroachdb endpoints pg
        {
          "vips": ["pg.cockroachdb.l4lb.thisdcos.directory:26257"],
          "address": [
            "10.0.2.77:26257",
            "10.0.0.61:26257",
            "10.0.1.215:26257"
          ],
          "dns": [
            "cockroachdb-0-node-init.cockroachdb.autoip.dcos.thisdcos.directory:26257",
            "cockroachdb-1-node-join.cockroachdb.autoip.dcos.thisdcos.directory:26257",
            "cockroachdb-2-node-join.cockroachdb.autoip.dcos.thisdcos.directory:26257"
          ],
          "vip": "pg.cockroachdb.l4lb.thisdcos.directory:26257"
        }
	```

  1. Open up a SQL shell to read and write data in your cluster by accessing the vip endpoint.

        ```
        $ dcos node ssh --master-proxy --leader
        $ docker run -it cockroachdb/cockroach sql --insecure --host=pg.cockroachdb.l4lb.thisdcos.directory
        # Welcome to the cockroach SQL interface.
        # All statements must be terminated by a semicolon.
        # To exit: CTRL + D.
        root@pg.cockroachdb.l4lb.thisdcos.directory:26257/> CREATE
        DATABASE bank;
        CREATE DATABASE
        root@pg.cockroachdb.l4lb.thisdcos.directory:26257/> CREATE TABLE
        bank.accounts (id INT PRIMARY KEY, balance DECIMAL);
        CREATE TABLE
        root@pg.cockroachdb.l4lb.thisdcos.directory:26257/> INSERT INTO
        bank.accounts VALUES (1234, 10000.50);
        INSERT 1
        root@pg.cockroachdb.l4lb.thisdcos.directory:26257/> SELECT * FROM
        bank.accounts;
        +------+----------+
        |  id  | balance  |
        +------+----------+
        | 1234 | 10000.50 |
        +------+----------+
        (1 row)
        ```

<a name="installing-and-customizing"></a>
# Installing and Customizing

The default CockroachDB installation provides reasonable defaults for trying out the service, but you may require different configurations depending on the context of your deployment.

## Prerequisities
- If you are using Enterprise DC/OS, you may [need to provision a service account](https://docs.mesosphere.com/1.9/security/service-auth/custom-service-auth/) before installing CockroachDB. Only someone with `superuser` permission can create the service account.
	- `strict` [security mode](https://docs.mesosphere.com/1.9/administration/installing/custom/configuration-parameters/#security) requires a service account.  
	- `permissive` security mode a service account is optional.
	- `disabled` security mode does not require a service account.
- Your cluster must have at least 3 private nodes.

## Installation from the DC/OS CLI

To start a basic test cluster, run the following command on the DC/OS CLI. Enterprise DC/OS users must follow additional instructions. [More information about installing CockroachDB on Enterprise DC/OS](https://docs.mesosphere.com/1.9/security/service-auth/custom-service-auth/).

```shell
dcos package install cockroachdb
```

You can specify a custom configuration in an `options.json` file and pass it to `dcos package install` using the `--options` parameter.

```shell
$ dcos package install cockroachdb --options=your-options.json
```

For more information about building the options.json file, see the [DC/OS documentation](https://docs.mesosphere.com/1.9/deploying-services/config-universe-service/) for service configuration access.

## Installation from the DC/OS Web Interface

You can [install CockroachDB from the DC/OS web interface](https://docs.mesosphere.com/1.9/usage/managing-services/install/). If you install CockroachDB from the web interface, you must install the CockroachDB DC/OS CLI subcommands separately. From the DC/OS CLI, enter:

```bash
dcos package install cockroachdb --cli
```

Choose `ADVANCED INSTALLATION` to perform a custom installation.

<a name="service-settings"></a>
## Service Settings

<a name="service-name"></a>
### Service Name

Each instance of CockroachDB in a given DC/OS cluster must be configured with a different service name. You can configure the service name in the **service** section of the advanced installation section of the DC/OS web interface. The default service name (used in many examples here) is `cockroachdb`.

<a name="node-settings"></a>
## Node Settings

Adjust the following settings to customize the amount of resources allocated to each node. CockroachDB's [system requirements](https://www.cockroachlabs.com/docs/stable/recommended-production-settings.html#hardware)_ must be taken into consideration when adjusting these values. Reducing these values below those requirements may result in adverse performance and/or failures while using the service.

Each of the following settings can be customized under the **node** configuration section.

<a name="node-count"></a>
### Node Count

Customize the `Node Count` setting (default 3) under the **node** configuration section. Consult the CockroachDB documentation for minimum node count requirements.

<a name="cpu"></a>
### CPU

You can customize the amount of CPU allocated to each node. A value of `1.0` equates to one full CPU core on a machine. Change this value by editing the **cpus** value under the **node** configuration section. Turning this too low will result in throttled tasks.

<a name="memory"></a>
### Memory

You can customize the amount of RAM allocated to each node. Change this value by editing the **mem** value (in MB) under the **node** configuration section. Turning this too low will result in out of memory errors.

<a name="ports"></a>
### Ports

You can customize the ports exposed by the service via the service configuratiton. If you wish to install multiple instances of the service and have them colocate on the same machines, you must ensure that **no** ports are common between those instances. Customizing ports is only needed if you require multiple instances sharing a single machine. This customization is optional otherwise.

There are two ports that can be customized: the `pg` port, which is used for inter-node communication and accepting client connections via the PostgreSQL wire protocol, and the `http` port which serves the CockroachDB Admin UI as well as some debug endpoints.

<a name="storage-volumes"></a>
### Storage Volumes

The service supports two volume types:
- `ROOT` volumes are effectively an isolated directory on the root volume, sharing IO/spindles with the rest of the host system.
- `MOUNT` volumes are a dedicated device or partition on a separate volume, with dedicated IO/spindles.

Using `MOUNT` volumes requires [additional configuration on each DC/OS agent system](https://docs.mesosphere.com/1.9/storage/mount-disk-resources/), so the service currently uses `ROOT` volumes by default. To ensure reliable and consistent performance in a production environment, you should configure `MOUNT` volumes on the machines that will run the service in your cluster and then configure the node `Disk Type` setting to use `MOUNT` volumes.

<a name="placement-constraints"></a>
### Placement Constraints

Placement constraints allow you to customize where the service is deployed in the DC/OS cluster. Placement constraints may be configured as a node parameter using the `Placement constraint` option.

Placement constraints support all [Marathon operators](http://mesosphere.github.io/marathon/docs/constraints.html) with this syntax: `field:OPERATOR[:parameter]`. For example, if the reference lists `[["hostname", "UNIQUE"]]`, use `hostname:UNIQUE`.

A common task is to specify a list of whitelisted systems to deploy to. To achieve this, use the following syntax for the placement constraint:

```
hostname:LIKE:10.0.0.159|10.0.1.202|10.0.3.3
```

You must include spare capacity in this list, so that if one of the whitelisted systems goes down, there is still enough room to repair your service without that system.

For an example of updating placement constraints, see [Managing](#managing) below.

### Overlay networks

CockroachDB supports deployment on the dcos overlay network, a virtual network on
DC/OS that allows each node to have its own IP address and not use the ports
resources on the agent. This can be specified by passing the following
configuration during installation:

```
{
    "service": {
        "virtual_network": true
    }
}
```

By default two nodes will not be placed on the same agent, however multiple
CockroachDB clusters can share an agent. As mentioned in the
[developer guide](https://mesosphere.github.io/dcos-commons/developer-guide.html)
once the service is deployed on the overlay network, it cannot be updated to use
the host network.

<a name="cockroachdb-settings"></a>
## CockroachDB Settings

Most CockroachDB settings are configured after the cluster has started, using
the `SET CLUSTER SETTING` SQL command. For information on how to set cluster
settings and which settings are available, please see [CockroachDB's
documentation](https://www.cockroachlabs.com/docs/stable/cluster-settings.html).

<a name="uninstalling"></a>
# Uninstalling

Follow these steps to uninstall the service.

1. Uninstall the service. From the DC/OS CLI, enter `dcos package uninstall`.
1. Clean up remaining reserved resources with the framework cleaner script, `janitor.py`. [More information about the framework cleaner script](https://docs.mesosphere.com/1.9/deploying-services/uninstall/#framework-cleaner). Note that this step is only needed for DC/OS versions older than 1.10.

To uninstall an instance named `cockroachdb` (the default), run:
``` shell
$ MY_SERVICE_NAME=cockroachdb
$ dcos package uninstall --app-id=$MY_SERVICE_NAME $MY_SERVICE_NAME
$ dcos node ssh --master-proxy --leader "docker run mesosphere/janitor /janitor.py \
      -r $MY_SERVICE_NAME-role \
      -p $MY_SERVICE_NAME-principal \
      -z dcos-service-$MY_SERVICE_NAME"
```

<a name="connecting-clients"></a>
# Connecting Clients

CockroachDB clients can use the standard PostgreSQL wire protocol for all
communication with the cluster, which means that existing PostgreSQL client
drivers can be used. A list of client drivers and ORMs (Object-Relational
Mappings) that have been tested to work can be found on
[the Cockroach Labs website](https://www.cockroachlabs.com/docs/stable/build-an-app-with-cockroachdb.html).
The CockroachDB binary also comes with an interactive SQL shell which you can
access via the `cockroach sql` command on the binary.

<a name="discovering-endpoints"></a>
## Discovering Endpoints

One of the benefits of running containerized services is that they can be placed anywhere in the cluster. Because they can be deployed anywhere on the cluster, clients need a way to find the service. This is where service discovery comes in.

Once the service is running, you may view information about its endpoints via either of the following methods:
- CLI:
  - List endpoint types: `dcos cockroachdb endpoints`
  - View endpoints for an endpoint type: `dcos cockroachdb endpoints <endpoint>`
- Web:
  - List endpoint types: `<dcos-url>/service/cockroachdb/v1/endpoints`
  - View endpoints for an endpoint type: `<dcos-url>/service/cockroachdb/v1/endpoints/<endpoint>`

Returned endpoints will include the following:
- `.mesos` hostnames for each instance that will follow them if they're moved within the DC/OS cluster.
- A HA-enabled VIP hostname for accessing any of the instances (optional).
- A direct IP address for accesssing the service if `.mesos` hostnames are not resolvable.

In general, the `.mesos` endpoints will only work from within the same DC/OS cluster. From outside the cluster you can either use the direct IPs or set up a proxy service that acts as a frontend to your CockroachDB instance. For development and testing purposes, you can use [DC/OS Tunnel](https://docs.mesosphere.com/latest/administration/access-node/tunnel/) to access services from outside the cluster, but this option is not suitable for production use.

<a name="connecting-clients-to-endpoints"></a>
## Connecting Clients to Endpoints

To use a DC/OS CockroachDB cluster, all you need to do is connect to the HA-enabled
VIP hostname from the above [Discovering Endpoints](#discovering-endpoints)
section using any PostgreSQL client driver.

For example, to connect using CockroachDB's built-in SQL client, you can open up a shell by running:

```
dcos node ssh --master-proxy --leader
docker run -it cockroachdb/cockroach sql --insecure --host=pg.cockroachdb.l4lb.thisdcos.directory
```

<a name="managing"></a>
# Managing

<a name="updating-configuration"></a>
## Updating Configuration

You can make changes to the service after it has been launched. Configuration management is handled by the scheduler process, which in turn handles deploying CockroachDB itself.

Edit the runtime environment of the scheduler to make configuration changes. After making a change, the scheduler will be restarted and automatically deploy any detected changes to the service, one node at a time. For example, a given change will first be applied to `cockroachdb-0`, then `cockroachdb-1`, and so on.

Nodes are configured with a "Readiness check" to ensure that the underlying service appears to be in a healthy state before continuing with applying a given change to the next node in the sequence. However, this basic check is not foolproof and reasonable care should be taken to ensure that a given configuration change will not negatively affect the behavior of the service.

Some changes, such as changing volume requirements, are not supported after initial deployment. See [Limitations](#limitations).

To make configuration changes via scheduler environment updates, perform the following steps:
1. Visit <dcos-url> to access the DC/OS web interface.
1. Navigate to `Services` and click on the service to be configured (default `cockroachdb`).
1. Click `Edit` in the upper right. On DC/OS 1.9.x, the `Edit` button is in a menu made up of three dots.
1. Navigate to `Environment` (or `Environment variables`) and search for the option to be updated.
1. Update the option value and click `Review and run` (or `Deploy changes`).
1. The Scheduler process will be restarted with the new configuration and will validate any detected changes.
1. If the detected changes pass validation, the relaunched Scheduler will deploy the changes by sequentially relaunching affected tasks as described above.

To see a full listing of available options, run `dcos package describe --config cockroachdb` in the CLI, or browse the CockroachDB install dialog in the DC/OS web interface.

<a name="adding-a-node"></a>
### Adding a Node
The service deploys 3 nodes by default. You can customize this value at initial deployment or after the cluster is already running. Shrinking the cluster is not supported.

Modify the `NODE_COUNT` environment variable to update the node count. If you decrease this value, the scheduler will prevent the configuration change until it is reverted back to its original value or larger.

<a name="resizing-a-node"></a>
### Resizing a Node
The CPU and Memory requirements of each node can be increased or decreased as follows:
- CPU (1.0 = 1 core): `NODE_CPUS`
- Memory (in MB): `NODE_MEM`

**Note:** Volume requirements (type and/or size) cannot be changed after initial deployment.

<a name="updating-placement-constraints"></a>
### Updating Placement Constraints

Placement constraints can be updated after initial deployment using the following procedure. See [Service Settings](#service-settings) above for more information on placement constraints.

Let's say we have the following deployment of our nodes

- Placement constraint of: `hostname:LIKE:10.0.10.3|10.0.10.8|10.0.10.26|10.0.10.28|10.0.10.84`
- Tasks:
```
10.0.10.3: cockroachdb-0
10.0.10.8: cockroachdb-1
10.0.10.26: cockroachdb-2
10.0.10.28: empty
10.0.10.84: empty
```

`10.0.10.8` is being decommissioned and we should move away from it. Steps:

1. Remove the decommissioned IP and add a new IP to the placement rule whitelist by editing `NODE_PLACEMENT`:

	```
	hostname:LIKE:10.0.10.3|10.0.10.26|10.0.10.28|10.0.10.84|10.0.10.123
	```
1. Redeploy `cockroachdb-1` from the decommissioned node to somewhere within the new whitelist: `dcos cockroachdb pods replace cockroachdb-1`
1. Wait for `cockroachdb-1` to be up and healthy before continuing with any other replacement operations.

<a name="restarting-a-node"></a>
## Restarting a Node

This operation will restart a node while keeping it at its current location and with its current persistent volume data. This may be thought of as similar to restarting a system process, but it also deletes any data that is not on a persistent volume.

1. Run `dcos cockroachdb pods restart cockroachdb-<NUM>`, e.g. `cockroachdb-2`.

<a name="replacing-a-node"></a>
## Replacing a Node

This operation will move a node to a new system and will discard the persistent volumes at the prior system to be rebuilt at the new system. Perform this operation if a given system is about to be offlined or has already been offlined.

**Note:** Nodes are not moved automatically. You must perform the following steps manually to move nodes to new systems. You can build your own automation to perform node replacement automatically according to your own preferences.

1. Run `dcos cockroachdb pods replace cockroachdb-<NUM>` to halt the current instance (if still running) and launch a new instance elsewhere.

For example, let's say `cockroachdb-3`'s host system has died and `cockroachdb-3` needs to be moved.

1. Start `cockroachdb-3` at a new location in the cluster by running:

	``` shell
	$ dcos cockroachdb pods replace cockroachdb-3
	```

<a name="disaster-recovery"></a>
# Disaster Recovery

Backing up and restoring data are critical pieces of behavior for any stateful
application storing important data. The functionality described below ensures
you can protect your data against all sorts of disasters.

The behavior included in this DC/OS framework uses standard SQL to dump and
restore all of your data, but if you have a very large database and need
[faster backups](https://www.cockroachlabs.com/docs/stable/backup.html),
[incremental backups](https://www.cockroachlabs.com/docs/stable/backup.html#incremental-backups),
or a [faster, distributed restore process](https://www.cockroachlabs.com/docs/stable/restore.html),
consider contacting Cockroach Labs about an
[enterprise license](https://www.cockroachlabs.com/pricing/).

<a name="backup"></a>
## Backup

### Backing up to S3

You can back up a CockroachDB cluster's data on a per-database basis using the
`dcos cockroachdb backup` CLI command, specifying the database name and S3
bucket as arguments. For example, to back up the data from a database named
`bank` to an S3 bucket named `cockroachdb-backup`, you would run:

```
dcos cockroachdb backup bank cockroachdb-backup
```

This will back up all tables contained within the database.
For more details on how the data is being backed up, please see the
[documentation of the underlying `cockroach dump`
command](https://www.cockroachlabs.com/docs/stable/sql-dump.html).

You can configure the communication with S3 using the following optional flags
to the CLI command:

* `--aws-access-key`: AWS Access Key
* `--aws-secret-key`: AWS Secret Key
* `--s3-dir`: AWS S3 target path
* `--s3-backup-dir`: Target path within s3-dir
* `--region=`: AWS region

By default, the AWS access and secret keys will be pulled from your environment
via the `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` environment variables,
respectively. You must either have these environment variables defined or
specify the flags for the backup to work.

Make sure that you provision your nodes with enough disk space to perform a
backup. The backups are stored on disk before being uploaded to S3,
and will take up as much space as the data currently in the tables, so you'll
need half of your total available space to be free to backup every keyspace at
once.

<a name="restore"></a>
## Restore

### Restoring from S3

Restoring cluster data is similar to backing it up. The `dcos cockroachdb restore`
CLI commmand assumes that your data is stored in an S3 bucket in the format that
the `dcos cockroachdb backup` command uses (or, alternatively, the format
generated by running the [`cockroach dump` command](https://www.cockroachlabs.com/docs/stable/sql-dump.html)).
The restore command is run like:

```
dcos cockroachdb restore [<flags>] <database> <s3-bucket> <s3-backup-dir>
```

And it takes the following optional flags:

* `--aws-access-key`: AWS Access Key
* `--aws-secret-key`: AWS Secret Key
* `--s3-dir`: AWS S3 target path
* `--region=`: AWS region

By default, the AWS access and secret keys will be pulled from your environment
via the `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` environment variables,
respectively. You must either have these environment variables defined or
specify the flags for the restore to work.

<a name="troubleshooting"></a>
# Troubleshooting

<a name="accessing-logs"></a>
## Accessing Logs

Logs for the scheduler and all service nodes can be viewed from the DC/OS web interface.

- Scheduler logs are useful for determining why a node isn't being launched (this is under the purview of the Scheduler).
- Node logs are useful for examining problems in the service itself.

In all cases, logs are generally piped to files named `stdout` and/or `stderr`.

To view logs for a given node, perform the following steps:
1. Visit <dcos-url> to access the DC/OS web interface.
1. Navigate to `Services` and click on the service to be examined (default `cockroachdb`).
1. In the list of tasks for the service, click on the task to be examined (scheduler is named after the service, nodes are `cockroachdb-0-node-init` or `cockroachdb-#-node-join`).
1. In the task details, click on the `Logs` tab to go into the log viewer. By default, you will see `stdout`, but `stderr` is also useful. Use the pull-down in the upper right to select the file to be examined.

You can also access the logs via the Mesos UI:
1. Visit <dcos-url>/mesos to view the Mesos UI.
1. Click the `Frameworks` tab in the upper left to get a list of services running in the cluster.
1. Navigate into the correct framework for your needs. The scheduler runs under `marathon` with a task name matching the service name (default `cockroachdb`). Service nodes run under a framework whose name matches the service name (default `cockroachdb`).
1. You should now see two lists of tasks. `Active Tasks` are tasks currently running, and `Completed Tasks` are tasks that have exited. Click the `Sandbox` link for the task you wish to examine.
1. The `Sandbox` view will list files named `stdout` and `stderr`. Click the file names to view the files in the browser, or click `Download` to download them to your system for local examination. Note that very old tasks will have their Sandbox automatically deleted to limit disk space usage.

<a name="limitations"></a>
# Limitations

<a name="removing-a-node"></a>
## Removing a Node

Removing a node is not supported at this time.

<a name="updating-storage-volumes"></a>
## Updating Storage Volumes

Neither volume type nor volume size requirements may be changed after initial deployment.

<a name="rack-aware-replication"></a>
## Rack-aware Replication

Rack placement and awareness are not supported at this time.

<a name="backup-storage"></a>
## Backup Storage

Storage of / restoring from backups in datastores other than S3 is not yet supported.

<a name="enterprise-backup-restore"></a>
## Enterprise Backup and Restore

The backup and restore functionality included in this DC/OS framework uses standard
SQL to dump and restore all of your data, but if you have a very large database and need
[faster backups](https://www.cockroachlabs.com/docs/stable/backup.html),
[incremental backups](https://www.cockroachlabs.com/docs/stable/backup.html#incremental-backups),
or a [faster, distributed restore process](https://www.cockroachlabs.com/docs/stable/restore.html),
consider contacting Cockroach Labs about an
[enterprise license](https://www.cockroachlabs.com/pricing/).

<a name="supported-versions"></a>
# Supported Versions

- CockroachDB: Supports versions 1.0 and above
- DC/OS: Tested on versions 1.9 and 1.10
