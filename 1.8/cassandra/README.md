# How to use Apache Cassandra on DC/OS

[Apache Cassandra](https://cassandra.apache.org/) is a distributed, structured storage system. Cassandra clusters are highly available, scalable, performant, and fault tolerant. DC/OS Cassandra allows you to quickly configure, install, and manage Apache Cassandra. Multiple Cassandra clusters can also be installed on DC/OS and managed independently, so you can offer Cassandra as a managed service to your organization.

- Estimated time for completion: 10 minutes
- Target Audience: Anyone who wants to deploy a distributed database on DC/OS. Beginner level.
- Scope:
 - Install the DC/OS Cassandra service.
 - Use the enhanced DC/OS CLI operations for Cassandra.
 - Validate that the service is up and running.
 - Connect to Cassandra and perform CRUD operations.

**Terminology**:

- **Node**: A running Cassandra instance.
- **Cluster**: Two or more Cassandra instances that communicate over gossip protocol.
- **Keyspace**: A namespace that defines how data is replicated on nodes.

**Table of Contents**:

- [Prerequisites](#prerequisites)
- [Install Cassandra](#install-cassandra)
  - [Typical installation](#typical-installation)
  - [Custom manual installation](#custom-manual-installation)
  - [Validate installation](#validate-installation)
- [CRUD operations](#perform-crud-operations)
- [Uninstall](#uninstall)

## Prerequisites

- A running DC/OS 1.8 cluster with 3 nodes each with 1.5 CPU shares, 5376MB of memory and 11264MB of disk for running Cassandra nodes and 1 node with 0.5 CPU shares, 2048MB of memory for running the service scheduler.
- [DC/OS CLI](https://dcos.io/docs/1.8/usage/cli/install/) installed.

## Install Cassandra

Assuming you have a DC/OS cluster up and running, the first step is to [install Cassandra](https://docs.mesosphere.com/manage-service/cassandra/).

### Typical installation

Install Cassandra using the DC/OS CLI:

```bash
$ dcos package install cassandra
DC/OS Cassandra Service default configuration requires 3 nodes each with 1.5 CPU shares, 5376MB of memory and 11264MB of disk for running Cassandra Nodes. And, 1 node with 0.5 CPU shares, 2048MB of memory for running the service scheduler.
Continue installing? [yes/no] yes
Installing Marathon app for package [cassandra] version [1.0.17-3.0.8]
Installing CLI subcommand for package [cassandra] version [1.0.17-3.0.8]
New command available: dcos cassandra
DC/OS Apache Cassandra has been successfully installed!

	Documentation: https://docs.mesosphere.com/current/usage/service-guides/cassandra/
	Issues: https://dcosjira.atlassian.net/projects/CASSANDRA/issues
```

Note that while the DC/OS CLI subcommand `cassandra` is immediately available, it takes a few moments for Cassandra to start running in the cluster.

### Custom manual installation

1. Verify existing DC/OS repositories:

    ```bash
    $ dcos package repo list
    Universe: https://universe.mesosphere.com/repo
    ```

1. Identify available versions for the Cassandra service.

    You can either list all available versions for Cassandra:

    ```bash
    $ dcos package list cassandra
    ```

    Or you can search for a particular one:

    ```bash
    $ dcos package search cassandra
    ```

1. Install a specific version of the Cassandra package:

    ```bash
    $ dcos package install --yes --force --package-version=<package_version> Cassandra
    ```

### Validate installation

Validate that the installation added the enhanced DC/OS CLI for Cassandra:

```bash
$ dcos cassandra --help
usage: cassandra [<flags>] <command> [<args> ...]

Deploy and manage Cassandra clusters

Flags:
  -h, --help              Show context-sensitive help (also try --help-long and
                          --help-man).
      --version           Show application version.
  -v, --verbose           Enable extra logging of requests/responses
      --info              Show short description.
      --force-insecure    Allow unverified TLS certificates when querying
                          service
      --custom-auth-token=DCOS_AUTH_TOKEN
                          Custom auth token to use when querying service
      --custom-dcos-url=DCOS_URI/DCOS_URL
                          Custom cluster URL to use when querying service
      --custom-cert-path=DCOS_CA_PATH/DCOS_CERT_PATH
                          Custom TLS CA certificate file to use when querying
                          service
      --name="cassandra"  Name of the service instance to query

Commands:
  help [<command>...]
    Show help.

  plan active
    Display the active operation chain, if any

  plan continue
    Continue a currently Waiting operation

  plan force
    Force the current operation to complete

  plan interrupt
    Interrupt the current InProgress operation

  plan restart
    Restart the current operation

  plan show
    Display the full plan

  seeds
    Retrieve seed node information

  connection [<flags>]
    Provides Cassandra connection information

  node describe [<task_name>]
    Describes a single node

  node list
    Lists all nodes

  node replace [<task_name>]
    Replaces a single node job, moving it to a different agent

  node restart [<task_name>]
    Restarts a single node job, keeping it on the same agent

  node status [<task_name>]
    Gets the status of a single node

  backup start [<flags>]
    Perform cluster backup via snapshot mechanism

  backup stop
    Stops a currently running backup

  backup status
    Displays the status of the backup

  restore start [<flags>]
    Restores cluster to a previous snapshot

  restore stop
    Stops a currently running restore

  restore status
    Displays the status of the restore

  cleanup start [<flags>]
    Perform cluster cleanup of deleted or moved keys

  cleanup stop
    Stops a currently running cleanup

  repair start [<flags>]
    Perform primary range anti-entropy repair

  repair stop
    Stops a currently running repair
```

In addition, you can go to the DC/OS UI to validate that the Cassandra service is running and healthy:

![Services](img/services.png)

## Perform CRUD operations

Retrieve the connection information:

```bash
$ dcos cassandra connection
{
  "address": [
    "10.0.3.228:9042",
    "10.0.3.230:9042",
    "10.0.3.227:9042"
  ],
  "dns": [
    "node-0.cassandra.mesos:9042",
    "node-1.cassandra.mesos:9042",
    "node-2.cassandra.mesos:9042"
  ],
  "vip": "node.cassandra.l4lb.thisdcos.directory:9042"
}
```

SSH into your DC/OS cluster to connect to your Cassandra cluster:

```
$ dcos node ssh --master-proxy --leader
core@ip-10-0-6-55 ~ $
```

You are now inside your DC/OS cluster and can connect to the Cassandra cluster directly. Connect to the cluster using the `cqlsh` client:

```bash
core@ip-10-0-6-153 ~ $ docker run -ti cassandra:3.0.7 cqlsh --cqlversion="3.4.0" <HOST>
```

Replace `<HOST>` with an IP from the `address` field, which we retrieved by running `dcos cassandra connection`, above:

```bash
core@ip-10-0-6-153 ~ $ docker run -ti cassandra:3.0.7 cqlsh --cqlversion="3.4.0" 10.0.3.228
cqlsh>
```

You are now connected to your Cassandra cluster. Let's create a sample keyspace called `demo`:

```sql
cqlsh> CREATE KEYSPACE demo WITH REPLICATION = { 'class' : 'SimpleStrategy', 'replication_factor' : 3 };
```

Next, create a sample table called `map` in the `demo` keyspace:

```sql
cqlsh> CREATE TABLE demo.map (key varchar, value varchar, PRIMARY KEY(key));
```

Insert some data in your table:

```sql
cqlsh> INSERT INTO demo.map(key, value) VALUES('Cassandra', 'Rocks!');
cqlsh> INSERT INTO demo.map(key, value) VALUES('StaticInfrastructure', 'BeGone!');
cqlsh> INSERT INTO demo.map(key, value) VALUES('Buzz', 'DC/OS is the new black!');
```

Query the data back to make sure it's persisted correctly:

```sql
cqlsh> SELECT * FROM demo.map;

 key                  | value
----------------------+-------------------------
            Cassandra |                  Rocks!
 StaticInfrastructure |                 BeGone!
                 Buzz | DC/OS is the new black!

(3 rows)
```

Next, delete some data:

```sql
cqlsh> DELETE FROM demo.map where key = 'StaticInfrastructure';
```

Query again to ensure that the row was deleted successfully:

```sql
cqlsh> SELECT * FROM demo.map;

 key       | value
-----------+-------------------------
 Cassandra |                  Rocks!
      Buzz | DC/OS is the new black!

(2 rows)
```

## Uninstall

```bash
$ dcos package uninstall cassandra
```

Use the [framework cleaner](/docs/1.8/usage/managing-services/uninstall/#framework-cleaner) script to remove your Cassandra instance from Zookeeper and to destroy all data associated with it. The script requires several arguments, the values for which are derived from your service name:

`framework-role` is `cassandra-role`
`framework-principal` is `cassandra-principal`
`zk_path` is `dcos-service-cassandra`

## Further resources

1. [DC/OS Cassandra Official Documentation](https://docs.mesosphere.com/1.8/usage/services/cassandra/)
1. [DataStax Cassandra Documentation](http://docs.datastax.com)
