# Percona Server for MongoDB Service Guide

[TOC]: # " "
- [Overview](#overview)
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Installation from the DC/OS CLI](#installation-from-the-dcos-cli)
- [Installation from the DC/OS Web Interface](#installation-from-the-dcos-web-interface)
- [Service Settings](#service-settings)
    - [Service Name](#service-name)
- [Mongo Settings](#mongo-settings)
    - [Node Count](#node-count)
    - [CPU](#cpu)
    - [Memory](#memory)
    - [Ports](#ports)
    - [Storage Volumes](#storage-volumes)
    - [Placement Constraints](#placement-constraints)
    - [DC/OS 1.10](#dcos-110)
    - [Older versions](#older-versions)
- [Discovering Endpoints](#discovering-endpoints)
- [Updating Configuration](#updating-configuration)
    - [Enterprise DC/OS 1.10](#enterprise-dcos-110)
    - [Open Source DC/OS, Enterprise DC/OS 1.9 and Earlier](#open-source-dcos-enterprise-dcos-19-and-earlier)
    - [Adding a Node](#adding-a-node)
    - [Resizing a Node](#resizing-a-node)
    - [Updating Placement Constraints](#updating-placement-constraints)
- [Restarting a Node](#restarting-a-node)
- [Replacing a Node](#replacing-a-node)
- [Upgrading Service Version](#upgrading-service-version)
- [Advanced update actions](#advanced-update-actions)
    - [Monitoring the update](#monitoring-the-update)
    - [Pause](#pause)
    - [Resume](#resume)
    - [Force Complete](#force-complete)
    - [Force Restart](#force-restart)
- [Backup Options](#backup-options)
- [Restore Options](#restore-options)
- [Accessing Logs](#accessing-logs)
- [Removing a Node](#removing-a-node)
- [Only ROOT Volumes Supported](#only-root-volumes)
- [Updating Storage Volumes](#updating-storage-volumes)
- [Rack-aware Replication](#rack-aware-replication)
- [Overlay network configuration updates](#overlay-network-configuration-updates)
- [Package Versioning Scheme](#package-versioning-scheme)
- [Contacting Technical Support](#contacting-technical-support)
    - [Mesosphere](#mesosphere)
- [Changelog](#changelog)
    - [0.1.0](#010)


<a name="overview"></a>
# Overview

'percona-mongo' is an automated service that makes it easy to deploy and manage a Percona Server for MongoDB Replica Set on [DC/OS](https://mesosphere.com/product/).

MongoDB is a flexible NoSQL document database. It stores records in a JSON-like format. Fields and data structure can be changed over time.

<a name="features"></a>
## Features

- Single command installation for rapid provisioning
- CLI for easy management
- Multiple Mongo clusters sharing a single DC/OS cluster for multi-tenancy
- Multiple Mongo instances sharing the same hosts for improved utilization
- Placement constraints for fine-grained instance placement
- Vertical and horizontal for managing capacity
- Rolling software and configuration updates for runtime maintainance

<a name="quick-start"></a>
# Quick Start

1. Install DC/OS on your cluster. See [the documentation](https://docs.mesosphere.com/latest/administration/installing/) for instructions.

2. If you are using open source DC/OS, install Mongo cluster with the following command from the DC/OS CLI. If you are using Enterprise DC/OS, you may need to follow additional instructions. See the Install and Customize section for more information.

	```
	dcos package install percona-mongo
	```

	You can also install 'percona-mongo' from [the DC/OS web interface](https://docs.mesosphere.com/latest/usage/webinterface/).

3. The service will now deploy with a default configuration. You can monitor its deployment from the Services tab of the DC/OS web interface.

4. Connect a client to MongoDB.
	```
	dcos percona-mongo endpoints
        [
          "mongo-port"
        ]
	dcos percona-mongo endpoints mongo-port
        {
          "address": [
            "10.0.3.53:27017",
            "10.0.3.159:27017",
            "10.0.1.211:27017"
          ],
          "dns": [
            "mongo-0-mongod.percona-mongo.autoip.dcos.thisdcos.directory:27017",
            "mongo-1-mongod.percona-mongo.autoip.dcos.thisdcos.directory:27017",
            "mongo-2-mongod.percona-mongo.autoip.dcos.thisdcos.directory:27017"
          ]
        }
	```

5. Connect to MongoDB and create a user and database called `products`.  

```
$ mongo clusteruseradmin:clusteruseradminpassword@mongo-0-mongod.percona-mongo.autoip.dcos.thisdcos.directory,mongo-1-mongod.percona-mongo.autoip.dcos.thisdcos.directory,mongo-2-mongod.percona-mongo.autoip.dcos.thisdcos.directory:27017/admin?replicaSet=rs
> db.getSiblingDB('admin').createUser({'user' : 'user', 'pwd' : 'pass', roles: [ { 'role' : 'readWrite', 'db' : 'products' } ]})
```

6. Connect to MongoDB with the user and add a product.

```
$ mongo user:pass@mongo-0-mongod.percona-mongo.autoip.dcos.thisdcos.directory,mongo-1-mongod.percona-mongo.autoip.dcos.thisdcos.directory,mongo-2-mongod.percona-mongo.autoip.dcos.thisdcos.directory:27017/admin?replicaSet=rs
> db.products.insert( { item: "card", qty: 15 } )
```

<a name="installing-and-customizing"></a>
# Installing and Customizing

The default Mongo installation provides reasonable defaults for trying out the service, but may not be sufficient for production use. You may require different configurations depending on the context of the deployment.

## Prerequisites
- If you are using Enterprise DC/OS, you may [need to provision a service account](https://docs.mesosphere.com/1.9/security/service-auth/custom-service-auth/) before installing Mongo. Only someone with `superuser` permission can create the service account.
	- `strict` [security mode](https://docs.mesosphere.com/1.9/administration/installing/custom/configuration-parameters/#security) requires a service account.  
	- `permissive` security mode a service account is optional.
	- `disabled` security mode does not require a service account.
- Your cluster must have at least 1 private node.

## Installation from the DC/OS CLI

To start a basic test cluster, run the following command on the DC/OS CLI. Enterprise DC/OS users must follow additional instructions. [More information about installing Mongo on Enterprise DC/OS](https://docs.mesosphere.com/1.9/security/service-auth/custom-service-auth/).

```shell
dcos package install percona-mongo
```

You can specify a custom configuration in an `options.json` file and pass it to `dcos package install` using the `--options` parameter.

```shell
dcos package install percona-mongo --options=your-options.json
```

**Recommendation:** Store your custom configuration in source control.

For more information about building the options.json file, see the [DC/OS documentation](https://docs.mesosphere.com/1.9/deploying-services/config-universe-service/) for service configuration access.

## Installation from the DC/OS Web Interface

You can [install percona-mongo from the DC/OS web interface](https://docs.mesosphere.com/1.9/usage/managing-services/install/). If you install 'percona-mongo' from the web interface, you must install the MongoDB DC/OS CLI subcommands separately. From the DC/OS CLI, enter:

```bash
dcos package install percona-mongo --cli
```

Choose `ADVANCED INSTALLATION` to perform a custom installation.

<a name="service-settings"></a>
## Service Settings

<a name="service-name"></a>
### Service Name

Each instance of Mongo in a given DC/OS cluster must be configured with a different service name. You can configure the service name in the **service** section of the advanced installation section of the DC/OS web interface. The default service name (used in many examples here) is `percona-mongo`.

<a name="mongo-settings"></a>
## MongoDB Settings

Adjust the following settings to customize the amount of resources allocated to each  node. Mongo's [system requirements](https://docs.mongodb.com/manual/administration/production-notes/) must be taken into consideration when adjusting these values. Reducing these values below those requirements may result in adverse performance and/or failures while using the service.

Each of the following settings can be customized under the **mongodb** configuration section.

<a name="node-count"></a>
### Node Count

Customize the **count** setting (default 3) under the **mongodb** configuration section. A minimum of 3 nodes is required for full High-Availability of MongoDB. Node count must be odd, eg: 3, 5, 7, 9, etc.

<a name="cpu"></a>
### CPU

You can customize the amount of CPU allocated to each node. A value of `1.0` equates to one full CPU core on a machine. Change this value by editing the **cpus** value under the **mongodb** configuration section. Turning this too low will result in throttled tasks.

<a name="memory"></a>
### Memory

You can customize the amount of RAM allocated to each node. Change this value by editing the **mem** value (in MB) under the **mongodb** configuration section. Turning this too low will result in out of memory errors.

<a name="ports"></a>
### Ports

You can customize the port number to use for each node. Change this value by editing the **port** value under the **mongodb** configuration section. This must be available within the system.

<a name="storage-volumes"></a>
### Storage Volumes

The service supports `ROOT` volumes only at this time.

<a name="placement-constraints"></a>
### Placement Constraints

Each pod requires the configured `mongodb.port` as a port resource. This requirement causes each 

<a name="uninstalling"></a>
# Uninstalling

<!-- THIS CONTENT DUPLICATES THE DC/OS OPERATION GUIDE -->

### DC/OS 1.10

If you are using DC/OS 1.10 and the installed service has a version greater than 2.0.0-x:

1. Uninstall the service. From the DC/OS CLI, enter `dcos package uninstall --app-id=<instancename> percona-mongo`.

For example, to uninstall a Mongo instance named `mongo-dev`, run:

```bash
dcos package uninstall --app-id=mongo-dev percona-mongo
```

### Older versions

If you are running DC/OS 1.9 or older, or a version of the service that is older than 2.0.0-x, follow these steps:

1. Stop the service. From the DC/OS CLI, enter `dcos package uninstall --app-id=<instancename> percona-mongo`.
   For example, `dcos package uninstall --app-id=mongo-dev percona-mongo`.
2. Clean up remaining reserved resources with the framework cleaner script, `janitor.py`. See [DC/OS documentation](https://docs.mesosphere.com/1.9/deploying-services/uninstall/#framework-cleaner) for more information about the framework cleaner script.

For example, to uninstall a MongoDB instance named `mongo-dev`, run:

```bash
$ MY_SERVICE_NAME=mongo-dev
$ dcos package uninstall --app-id=$MY_SERVICE_NAME percona-mongo`.
$ dcos node ssh --master-proxy --leader "docker run --net host mesosphere/janitor /janitor.py \
    -r $MY_SERVICE_NAME-role \
    -p $MY_SERVICE_NAME-principal \
    -z dcos-service-$MY_SERVICE_NAME"
```

<!-- END DUPLICATE BLOCK -->

<a name="connecting-clients"></a>
# Connecting Clients

One of the benefits of running containerized services is that they can be placed anywhere in the cluster. Because they can be deployed anywhere on the cluster, clients need a way to find the service. This is where service discovery comes in.

<a name="discovering-endpoints"></a>
## Discovering Endpoints

Once the service is running, you may view information about its endpoints via either of the following methods:
- CLI:
  - List endpoint types: `dcos percona-mongo endpoints`
  - View endpoints for an endpoint type: `dcos percona-mongo endpoints <endpoint>`
- Web:
  - List endpoint types: `<dcos-url>/service/percona-mongo/v1/endpoints`
  - View endpoints for an endpoint type: `<dcos-url>/service/percona-mongo/v1/endpoints/<endpoint>`

Returned endpoints will include the following:
- `.autoip.dcos.thisdcos.directory` hostnames for each instance that will follow them if they're moved within the DC/OS cluster.
- A direct IP address for accesssing the service if `.autoip.dcos.thisdcos.directory` hostnames are not resolvable.
- If your service is on the `dcos` overlay network, then the IP will be from the subnet allocated to the host that the task is running on. It will not be the host IP. To resolve the host IP use Mesos DNS (`<task>.<service>.mesos`).

In general, the `.autoip.dcos.thisdcos.directory` endpoints will only work from within the same DC/OS cluster. From outside the cluster you can either use the direct IPs or set up a proxy service that acts as a frontend to your Mongo instance. For development and testing purposes, you can use [DC/OS Tunnel](https://docs.mesosphere.com/latest/administration/access-node/tunnel/) to access services from outside the cluster, but this option is not suitable for production use.

<a name="managing"></a>
# Managing

<a name="updating-configuration"></a>
## Updating Configuration

**Note: Items in this section have not yet been verified in this alpha release.**

You can make changes to the service after it has been launched. Configuration management is handled by the scheduler process, which in turn handles deploying MongoDB itself.

After making a change, the scheduler will be restarted and will automatically deploy any detected changes to the service, one node at a time. For example, a given change will first be applied to `_NODEPOD_-0`, then `_NODEPOD_-1`, and so on.

Nodes are configured with a "Readiness check" to ensure that the underlying service appears to be in a healthy state before continuing with applying a given change to the next node in the sequence. However, this basic check is not foolproof and reasonable care should be taken to ensure that a given configuration change will not negatively affect the behavior of the service.

Some changes, such as decreasing the number of nodes or changing volume requirements, are not supported after initial deployment. See [Limitations](#limitations).

<!-- THIS CONTENT DUPLICATES THE DC/OS OPERATION GUIDE -->

The instructions below describe how to update the configuration for a running DC/OS service.

### Enterprise DC/OS 1.10

Enterprise DC/OS 1.10 introduces a convenient command line option that allows for easier updates to a service's configuration, as well as allowing users to inspect the status of an update, to pause and resume updates, and to restart or complete steps if necessary.

#### Prerequisites

+ Enterprise DC/OS 1.10 or newer.
+ Service with a version greater than 2.0.0-x.
+ [The DC/OS CLI](https://docs.mesosphere.com/latest/cli/install/) installed and available.
+ The service's subcommand available and installed on your local machine.
  + You can install just the subcommand CLI by running `dcos package install --cli percona-mongo`.
  + If you are running an older version of the subcommand CLI that doesn't have the `update` command, uninstall and reinstall your CLI.
    ```bash
    dcos package uninstall --cli percona-mongo
    dcos package install --cli percona-mongo
    ```

#### Preparing configuration

If you installed this service with Enterprise DC/OS 1.10, you can fetch the full configuration of a service (including any default values that were applied during installation). For example:

```bash
$ dcos percona-mongo describe > options.json
```

Make any configuration changes to this `options.json` file.

If you installed this service with a prior version of DC/OS, this configuration will not have been persisted by the the DC/OS package manager. You can instead use the `options.json` file that was used when [installing the service](#initial-service-configuration).

<strong>Note:</strong> You need to specify all configuration values in the `options.json` file when performing a configuration update. Any unspecified values will be reverted to the default values specified by the DC/OS service. See the "Recreating `options.json`" section below for information on recovering these values.

##### Recreating `options.json` (optional)

If the `options.json` from when the service was last installed or updated is not available, you will need to manually recreate it using the following steps.

First, we'll fetch the default application's environment, current application's environment, and the actual mongo that maps config values to the environment:

1. Ensure you have [jq](https://stedolan.github.io/jq/) installed.
2. Set the service name that you're using, for example:
```bash
$ SERVICE_NAME=percona-mongo
```
3. Get the version of the package that is currently installed:
```bash
$ PACKAGE_VERSION=$(dcos package list | grep $SERVICE_NAME | awk '{print $2}')
```
4. Then fetch and save the environment variables that have been set for the service:
```bash
$ dcos marathon app show $SERVICE_NAME | jq .env > current_env.json
```
5. To identify those values that are custom, we'll get the default environment variables for this version of the service:
```bash
$ dcos package describe --package-version=$PACKAGE_VERSION --render --app $SERVICE_NAME | jq .env > default_env.json
```
6. We'll also get the entire application mongo:
```bash
$ dcos package describe $SERVICE_NAME --app > marathon.json.mustache
```

Now that you have these files, we'll attempt to recreate the `options.json`.

7. Use JQ and `diff` to compare the two:
```bash
$ diff <(jq -S . default_env.json) <(jq -S . current_env.json)
```
8. Now compare these values to the values contained in the `env` section in application mongo:
```bash
$ less marathon.json.mustache
```
9. Use the variable names (e.g. `{{service.name}}`) to create a new `options.json` file as described in [Initial service configuration](#initial-service-configuration).

#### Starting the update

Once you are ready to begin, initiate an update using the DC/OS CLI, passing in the updated `options.json` file:

```bash
$ dcos percona-mongo update start --options=options.json
```

You will receive an acknowledgement message and the DC/OS package manager will restart the Scheduler in Marathon.

See [Advanced update actions](#advanced-update-actions) for commands you can use to inspect and manipulate an update after it has started.

### Open Source DC/OS, Enterprise DC/OS 1.9 and Earlier

If you do not have Enterprise DC/OS 1.10 or later, the CLI commands above are not available. For Open Source DC/OS of any version, or Enterprise DC/OS 1.9 and earlier, you can perform changes from the DC/OS GUI.

<!-- END DUPLICATE BLOCK -->

To make configuration changes via scheduler environment updates, perform the following steps:
1. Visit <dcos-url> to access the DC/OS web interface.
2. Navigate to `Services` and click on the service to be configured (default _`PKGNAME`_).
3. Click `Edit` in the upper right. On DC/OS 1.9.x, the `Edit` button is in a menu made up of three dots.
4. Navigate to `Environment` (or `Environment variables`) and search for the option to be updated.
5. Update the option value and click `Review and run` (or `Deploy changes`).
6. The Scheduler process will be restarted with the new configuration and will validate any detected changes.
7. If the detected changes pass validation, the relaunched Scheduler will deploy the changes by sequentially relaunching affected tasks as described above.

To see a full listing of available options, run `dcos package describe --config percona-mongo` in the CLI, or browse the _SERVICE NAME_ install dialog in the DC/OS web interface.

<a name="adding-a-node"></a>
### Adding a Node
The service deploys 3 nodes by default. You can customize this value at initial deployment or after the cluster is already running. Shrinking the cluster is not supported.

Modify the `MONGODB_COUNT` environment variable to update the node count. If you decrease this value, the scheduler will prevent the configuration change until it is reverted back to its original value or larger.

<a name="resizing-a-node"></a>
### Resizing a Node
The CPU and Memory requirements of each node can be increased or decreased as follows:
- CPU (1.0 = 1 core): `MONGODB_CPUS`
- Memory (in MB): `MONGODB_MEM`

**Note:** Volume requirements (type and/or size) cannot be changed after initial deployment.

<a name="restarting-a-node"></a>
## Restarting a Node

This operation will restart a node while keeping it at its current location and with its current persistent volume data. This may be thought of as similar to restarting a system process, but it also deletes any data that is not on a persistent volume.

1. Run `dcos percona-mongo pod restart mongo-<NUM>`, e.g. `mongo-2`.

<a name="replacing-a-node"></a>
## Replacing a Node

This operation will move a node to a new system and will discard the persistent volumes at the prior system to be rebuilt at the new system. Perform this operation if a given system is about to be offlined or has already been offlined.

**Note:** Nodes are not moved automatically. You must perform the following steps manually to move nodes to new systems. You can build your own automation to perform node replacement automatically according to your own preferences.

1. Run `dcos percona-mongo pod replace mongo-<NUM>` to halt the current instance (if still running) and launch a new instance elsewhere.

<a name="upgrading"></a>
## Upgrading Service Version

<!-- THIS CONTENT DUPLICATES THE DC/OS OPERATION GUIDE -->

The instructions below show how to safely update one version of Mongo to the next.

##### Viewing available versions

The `update package-versions` command allows you to view the versions of a service that you can upgrade or downgrade to. These are specified by the service maintainer and depend on the semantics of the service (i.e. whether or not upgrades are reversal).

For example, run:
```bash
$ dcos percona-mongo update package-versions
```

##### Upgrading or downgrading a service

**Note: Items in this section have not yet been verified in this alpha release.**

1. Before updating the service itself, update its CLI subcommand to the new version:
```bash
$ dcos package uninstall --cli percona-mongo
$ dcos package install --cli percona-mongo --package-version="1.1.6-5.0.7"
```
2. Once the CLI subcommand has been updated, call the update start command, passing in the version. For example, to update Mongo to version `1.1.6-5.0.7`:
```bash
$ dcos percona-mongo update start --package-version="1.1.6-5.0.7"
```

If you are missing mandatory configuration parameters, the `update` command will return an error. To supply missing values, you can also provide an `options.json` file (see [Updating configuration](#updating-configuration)):
```bash
$ dcos percona-mongo update start --options=options.json --package-version="1.1.6-5.0.7"
```

See [Advanced update actions](#advanced-update-actions) for commands you can use to inspect and manipulate an update after it has started.

<!-- END DUPLICATE BLOCK -->

## Advanced update actions

<!-- THIS CONTENT DUPLICATES THE DC/OS OPERATION GUIDE -->

The following sections describe advanced commands that be used to interact with an update in progress.

### Monitoring the update

Once the Scheduler has been restarted, it will begin a new deployment plan as individual pods are restarted with the new configuration. Depending on the high availability characteristics of the service being updated, you may experience a service disruption.

You can query the status of the update as follows:

```bash
$ dcos percona-mongo update status
```

If the Scheduler is still restarting, DC/OS will not be able to route to it and this command will return an error message. Wait a short while and try again. You can also go to the Services tab of the DC/OS GUI to check the status of the restart.

### Pause

To pause an ongoing update, issue a pause command:

```bash
$ dcos percona-mongo update pause
```

You will receive an error message if the plan has already completed or has been paused. Once completed, the plan will enter the `WAITING` state.

### Resume

If a plan is in a `WAITING` state, as a result of being paused or reaching a breakpoint that requires manual operator verification, you can use the `resume` command to continue the plan:

```bash
$ dcos percona-mongo update resume
```

You will receive an error message if you attempt to `resume` a plan that is already in progress or has already completed.

### Force Complete

In order to manually "complete" a step (such that the Scheduler stops attempting to launch a task), you can issue a `force-complete` command. This will instruct to Scheduler to mark a specific step within a phase as complete. You need to specify both the phase and the step, for example:

```bash
$ dcos percona-mongo update force-complete service-phase service-0:[node]
```

### Force Restart

Similar to force complete, you can also force a restart. This can either be done for an entire plan, a phase, or just for a specific step.

To restart the entire plan:
```bash
$ dcos percona-mongo update force-restart
```

Or for all steps in a single phase:
```bash
$ dcos percona-mongo update force-restart service-phase
```

Or for a specific step within a specific phase:
```bash
$ dcos percona-mongo update force-restart service-phase service-0:[node]
```

<!-- END DUPLICATE BLOCK -->

<a name="disaster-recovery"></a>
# Disaster Recovery

<a name="troubleshooting"></a>
# Troubleshooting

TODO

<a name="backup-options"></a>
## Backup Options

MongoDB Backups via DCOS are not supported in this Alpha release.

We recommend [Percona-Lab/mongodb_consistent_backup](https://github.com/Percona-Lab/mongodb_consistent_backup) or [mongodump](https://docs.mongodb.com/manual/reference/program/mongodump/) is used to create manual backups against the DCOS service endpoint until backups are supported. Note: the '--oplog' flag should be added to the mongodump command for point-in-time consistency.

<a name="restore-options"></a>
## Restore Options

MongoDB Restores via DCOS are not supported in this Alpha release.

We recommend [mongorestore](https://docs.mongodb.com/manual/reference/program/mongorestore/) is used to restore backups manually against the service endpoint until restores are supported. Use the '--oplogReplay' flag with mongorestore to restore with point-in-time consistency.

<a name="accessing-logs"></a>
## Accessing Logs

Logs for the scheduler and all service nodes can be viewed from the DC/OS web interface.

- Scheduler logs are useful for determining why a node isn't being launched (this is under the purview of the Scheduler).
- Node logs are useful for examining problems in the service itself.

In all cases, logs are generally piped to files named `stdout` and/or `stderr`.

To view logs for a given node, perform the following steps:
1. Visit <dcos-url> to access the DC/OS web interface.
2. Navigate to `Services` and click on the service to be examined (default _`PKGNAME`_).
3. In the list of tasks for the service, click on the task to be examined (scheduler is named after the service, nodes are each `_NODEPOD_-#-node`).
4. In the task details, click on the `Logs` tab to go into the log viewer. By default, you will see `stdout`, but `stderr` is also useful. Use the pull-down in the upper right to select the file to be examined.

You can also access the logs via the Mesos UI:
1. Visit <dcos-url>/mesos to view the Mesos UI.
2. Click the `Frameworks` tab in the upper left to get a list of services running in the cluster.
3. Navigate into the correct framework for your needs. The scheduler runs under `marathon` with a task name matching the service name (default _`PKGNAME`_). Service nodes run under a framework whose name matches the service name (default _`PKGNAME`_).
4. You should now see two lists of tasks. `Active Tasks` are tasks currently running, and `Completed Tasks` are tasks that have exited. Click the `Sandbox` link for the task you wish to examine.
5. The `Sandbox` view will list files named `stdout` and `stderr`. Click the file names to view the files in the browser, or click `Download` to download them to your system for local examination. Note that very old tasks will have their Sandbox automatically deleted to limit disk space usage.


<a name="limitations"></a>
# Limitations

## Limitations because of issues in DC/OS and the SDK

The table below shows all limitations of the MongoDB service that are the result of issues in [DC/OS in JIRA](https://jira.mesosphere.com/browse/DCOS_OSS/issues) or the [DC/OS SDK in Github](https://github.com/mesosphere/dcos-commons).

| Limitation                                                                    | Description                                                                                                                                                                                                                                                                             | Bugs                                                                                                                              |
|:------------------------------------------------------------------------------|:----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|:----------------------------------------------------------------------------------------------------------------------------------|
| MongoDB keyFile and passwords are predictable.                                | The backup, userAdmin, clusterMonitor and clusterAdmin users have predictable default passwords. Also, the MongoDB keyFile has a predictable default. A feature request has been opened to generate secure random keys/passwords. | [DCOS_OSS-1917](https://jira.mesosphere.com/browse/DCOS_OSS-1917) |
| MongoDB database path not visible in DCOS UI.                                 | The MongoDB database directory (dbPath) displays an empty directory in the DCOS UI 'Files' page for a mongod instance. Database files, diagnostic data and optional auditLog cannot be read via the 'Files' UI page as a result.  | [DCOS_OSS-1989](https://jira.mesosphere.com/browse/DCOS_OSS-1989) |
| MongoDB SSL Connections are not supported.                                    | MongoDB SSL/TLS connections are not yet supported. This feature is coming soon. | |
| Automated MongoDB Backups not yet supported.                                  | Automation of MongoDB backups is not yet supported. This feature is coming soon. | |
| Manual Backup and User-creation automation not yet supported.                 | CLI tasks for triggering backups and creating users is not yet supported. This feature is coming soon. | |
| Scaling up/down Replica Set nodes not yet supported.                          | The ability to scale up/down a MongoDB Replica Set is not yet supported. | |
| Emit app metrics to DC/OS Metrics module.                                     | DC/OS Metrics are currently not supported by this framework. This feature is coming soon. | |
| Ability to scale down (dcos-commons validation constraint)                    | Add ability to scale down. | |
| Rollback upon failure                                                         | When a configuration change is triggered for an existing MongoDB cluster within Mesosphere DC/OS and that change causes a failure, a rollback should be triggered thus that the existing instances running in the cluster are not killed by the scheduler. |  |
| Configurable Service Account and Secret for Enterprise DC/OS Strict Security Mode. | Add support for configurable Service Account and Service Account Secret for Enterprise DC/OS Strict Security Mode | |
| Documentation for certification  | Add documentation that follows the DC/OS Service Guide | |
| Config: Memory swapiness | Currently the framework is unable to set Virtual Memory swapiness to a recommended value for MongoDB. | |
| Config: XFS Formatting | Currently the framework is unable to enforce an XFS-based filesystem for storing MongoDB data. **We strongly recommend WiredTiger-based installations *(the default)* run on DC/OS agent nodes using the XFS filesystem only! We also suggest the EXT3 filesystem is avoided due to poor performance.** | |
| Config: Transparent HugePages | Currently the framework is unable to set Transparent HugePages *(RedHat/Fedora/CentOS-only)* to a recommended value for MongoDB. **We recommend THP is disabled entirely on DC/OS agent nodes running this framework!** | |
| Support install of Percona PMM monitoring client for MongoDB | Add support for automated installation of Percona Monitoring and Management client for MongoDB. | |
| Dashboard does not show service health checks                                 | The MongoDB service has health checks configured but they are not picked up by the Dashboard UI.                                                                                                                                                                                        | [DCOS_OSS-982](https://jira.mesosphere.com/browse/DCOS_OSS-982) [DCOS_OSS-1348](https://jira.mesosphere.com/browse/DCOS_OSS-1348) |
| Missing integration test because of `shakedown` bug | This service should have an integration test for testing scaling and cluster failover but this is blocked by an accept header bug in `shakedown` | [DCOS_OSS-1399](https://jira.mesosphere.com/browse/DCOS_OSS-1399) |

## General limitations

Below are some general limitations of the service.


## Service user		
		
The DC/OS Mongo Service uses a Docker image to manage its dependencies for Percona Server for MongoDB. Since the Docker image contains a full Linux userspace with its own `/etc/users` file, it is possible for the default service user `nobody` to have a different UID inside the container than on the host system. Although user `nobody` has UID `65534` by convention on many systems, this is not always the case. As Mesos does not perform UID mapping between Linux user namespaces, specifying a service user of `nobody` in this case will cause access failures when the container user attempts to open or execute a filesystem resource owned by a user with a different UID, preventing the service from launching. If the hosts in your cluster have a UID for `nobody` other than 65534, you will need to specify a service user of `root` to run DC/OS Mongo Service.
		
To determine the UID of `nobody`, run the command `id nobody` on a host in your cluster:		
```		
$ id nobody		
uid=65534(nobody) gid=65534(nobody) groups=65534(nobody)		
```		
		
If the returned UID is not `65534`, then the DC/OS Mongo Service can be installed as root by setting the service user at install time:		
```		
"service": {		
        "user": "root",		
        ...		
}		
...		
```

<a name="MongoDB Configuration: General"></a>
## MongoDB Configuration: General

The framework currently supports the [configuration file options](https://docs.mongodb.com/v3.4/reference/configuration-options/) available in MongoDB version 3.4 only!

For stability, configuration options marked *"experimental"* or *"deprecated"* are not configurable via the DC/OS UI.

<a name="MongoDB Configuration: Security"></a>
## MongoDB Configuration: Security

For security, this framework requires [MongoDB Authentication](https://docs.mongodb.com/manual/core/authentication/) and [MongoDB Internal Authentication](https://docs.mongodb.com/manual/core/security-internal-authentication/) is enabled. These configuration options cannot be changed as a result. **Your application and MongoDB database driver must support (and utilise) [MongoDB Authentication](https://docs.mongodb.com/manual/core/authentication/) to use this framework!**

Passwords and Internal Authentication keyFile can be manually defined at service creation time, otherwise a default is used. We **strongly recommend** you change the default key and passwords to something unique and secure!

<a name="MongoDB Configuration: Storage"></a>
## MongoDB Configuration: Storage

Currently storage engine cache sizes cannot be defined when using WiredTiger, InMemory or RocksDB as a storage engine.

These storage engines will use their default logic to determine a cache size value, which is typically 50% of the container available memory.

<a name="removing-a-node"></a>
## Removing a Node

Removing a node is not supported at this time.

<a name="only-root-volumes"></a>
## Only ROOT Volumes Supported

The service only supports ROOT volumes and not MOUNT volumes with absolute paths because of a validation error. This requires a custom scheduler.

<a name="updating-storage-volumes"></a>
## Updating Storage Volumes

Volume size requirements may be changed after initial deployment.

<a name="rack-aware-replication"></a>
## Rack-aware Replication

Rack placement and awareness are not supported at this time.

## Overlay network configuration updates
When a pod from your service uses the overlay network, it does not use the port resources on the agent machine, and thus does not have them reserved. For this reason, we do not allow a pod deployed on the overlay network to be updated (moved) to the host network, because we cannot guarantee that the machine with the reserved volumes will have ports available. To make the reasoning simpler, we also do not allow for pods to be moved from the host network to the overlay. Once you pick a networking paradigm for your service the service is bound to that networking paradigm.

<a name="support"></a>
# Support

<a name="package-versioning-scheme"></a>
## Package Versioning Scheme

- MongoDB: See the framework description
- DC/OS: 1.10

<a name="contacting-technical-support"></a>
## Contacting Technical Support

Please contact [mesosphere@percona.com](mailto:mesosphere@percona.com)

<a name="changelog"></a>
## Changelog

### 0.1.0
#### Breaking Changes
#### New Features
#### Improvements
#### Bug Fixes
