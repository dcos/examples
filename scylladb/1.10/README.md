# Getting started with ScyllaDB on DC/OS

[ScyllaDB](https://scylladb.com) is a drop-in Apache Cassandra replacement that powers your applications with ultra-low latency and extreme throughput. Leveraging the best from Apache Cassandra in high availability, fault tolerance, and its rich ecosystem, Scylla offers developers a dramatically higher-performing and resource effective NoSQL database to power modern and demanding applications.

**Table of Contents**:

- [Prerequisites](#prerequisites)
- [Installing ScyllaDB](#installing-scylladb)
  - [Service](#service)
  - [General](#general)
  - [Disks](#disks)
  - [Network](#network)
  - [Security](#security)
  - [Validate installation](#validate-installation)
- [Uninstall](#uninstall)

## Prerequisites

- A running DC/OS 1.10 cluster 
- At least 4 Gb of memory and 1.0 CPU shares available on each node that you want to run Scylla on

## Installing ScyllaDB
Scylla on DC/OS demands to be manually configured before deployment. So in order to get started, head over to the DC/OS catalog find the ScyllaDB package and press *Configure* to get started.

### Service
In Service we define the basics of each container we will deploy on DC/OS:
**Name** - application name that we will use as reference with the DC/OS CLI for example.  
**Nodes** - number of nodes in your ScyllaDB cluster. This can be scaled up and down later, however the number of seed nodes can not be changed from the inital number.  
**SMP** - the number of CPU cores each ScyllaDB instance will have. From DC/OS 1.10 the [CFS scheduler](https://github.com/mesosphere/marathon/blob/master/docs/docs/cfs.md) is implemented.
**Memory** - the amount of memory per instance in Mb. Try to keep the guidelines in the [ScyllaDB documentation](http://docs.scylladb.com/getting-started/system-requirements/) when it comes to Mem/CPU ratio.

### General
In General we set more Scylla specific settings for each instance:


### Disks


### Network


### Security



### Validate installation

Validate that the installation added the enhanced DC/OS CLI for Cassandra:

```bash
$ dcos cassandra --help-long
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


  plan list
    Show all plans for this service


  plan show [<plan>]
    Display the deploy plan or the plan with the provided name


  plan start <plan> [<params>]
    Start the plan with the provided name, with optional envvars to supply to
    task


  plan stop <plan>
    Stop the plan with the provided name


  plan continue [<plan>]
    Continue the deploy plan or the plan with the provided name


  plan interrupt [<plan>]
    Interrupt the deploy plan or the plan with the provided name


  plan restart <plan> <phase> <step>
    Restart the plan with the provided name


  plan force <plan> <phase> <step>
    Force complete the plan with the provided name


  seeds
    Retrieve seed node information


  connection [<flags>]
    Provides Cassandra connection information

    --address  Provide addresses of the Cassandra nodes
    --dns      Provide dns names of the Cassandra nodes

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

    --backup_name=BACKUP_NAME      Name of the snapshot
    --external_location=EXTERNAL_LOCATION
                                   External location where the snapshot should
                                   be stored
    --s3_access_key=S3_ACCESS_KEY  S3 access key
    --s3_secret_key=S3_SECRET_KEY  S3 secret key
    --azure_account=AZURE_ACCOUNT  Azure storage account
    --azure_key=AZURE_KEY          Azure secret key

  backup stop
    Stops a currently running backup


  backup status
    Displays the status of the backup


  restore start [<flags>]
    Restores cluster to a previous snapshot

    --backup_name=BACKUP_NAME      Name of the snapshot to restore
    --external_location=EXTERNAL_LOCATION
                                   External location where the snapshot is
                                   stored
    --s3_access_key=S3_ACCESS_KEY  S3 access key
    --s3_secret_key=S3_SECRET_KEY  S3 secret key
    --azure_account=AZURE_ACCOUNT  Azure storage account
    --azure_key=AZURE_KEY          Azure secret key

  restore stop
    Stops a currently running restore


  restore status
    Displays the status of the restore


  cleanup start [<flags>]
    Perform cluster cleanup of deleted or moved keys

    --nodes="*"              A list of the nodes to cleanup or * for all.
    --key_spaces=KEY_SPACES  The key spaces to cleanup or empty for all.
    --column_families=COLUMN_FAMILIES
                             The column families to cleanup.

  cleanup stop
    Stops a currently running cleanup


  repair start [<flags>]
    Perform primary range anti-entropy repair

    --nodes="*"              A list of the nodes to repair or * for all.
    --key_spaces=KEY_SPACES  The key spaces to repair or empty for all.
    --column_families=COLUMN_FAMILIES
                             The column families to repair.

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
core@ip-10-0-6-153 ~ $ docker run -ti cassandra:3.0.10 cqlsh --cqlversion="3.4.0" <HOST>
```

Replace `<HOST>` with an IP from the `address` field, which we retrieved by running `dcos cassandra connection`, above:

```bash
core@ip-10-0-6-153 ~ $ docker run -ti cassandra:3.0.10 cqlsh --cqlversion="3.4.0" 10.0.3.228
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

To uninstall Cassandra:

```bash
$ dcos package uninstall cassandra
WARNING: This action cannot be undone. This will uninstall [cassandra] and delete all of its persistent data (logs, configurations, database artifacts, everything).
Please type the name of the service to confirm: cassandra
Uninstalled package [cassandra] version [1.0.25-3.0.10]
DC/OS Apache Cassandra service has been uninstalled.
Please follow the instructions at https://docs.mesosphere.com/current/usage/service-guides/cassandra/uninstall to remove any persistent state if required.
```

Use the [framework cleaner](https://docs.mesosphere.com/1.10/deploying-services/uninstall/#framework-cleaner) script to remove your Cassandra instance from ZooKeeper and to destroy all data associated with it. The script requires several arguments, the values for which are derived from your service name:

```bash
# connect to the leader if you are not already
dcos node ssh --master-proxy --leader

docker run mesosphere/janitor /janitor.py -r cassandra-role -p cassandra-principal -z dcos-service-cassandra
```
- `framework-role` is `cassandra-role`
- `framework-principal` is `cassandra-principal`
- `zk_path` is `dcos-service-cassandra`

## Further resources

1. [DC/OS Cassandra Official Documentation](https://docs.mesosphere.com/service-docs/cassandra/v1.0.25-3.0.10)
1. [DataStax Cassandra Documentation](http://docs.datastax.com)
