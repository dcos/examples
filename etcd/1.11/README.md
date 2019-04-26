# etcd

[etcd](https://etcd.io) is an open-source distributed key-value store. Using the DC/OS etcd package you can install and manage a distributed and highly available cluster of etcd nodes in your DC/OS cluster.

## Requirements

* DC/OS cluster running at least version 1.11 (both OSS and EE are supported)
* Installed and configured dcos cli
* At least 4 cores and 2 GB RAM free on your cluster

## Quickstart

```bash
dcos package install etcd
```

By default the package will install 3 nodes. Check the DC/OS UI to see if all of the nodes have been started.
Log into a node in your cluster (e.g. by using `dcos node ssh --master-proxy --leader`) and run the following to test the HTTP API of etcd:

```bash
$ curl -X PUT http://api.etcd.l4lb.thisdcos.directory:2379/v2/keys/hello -d value=world
{"action":"set","node":{"key":"/hello","value":"world","modifiedIndex":1,"createdIndex":1}}

$ curl http://api.etcd.l4lb.thisdcos.directory:2379/v2/keys/hello
{"action":"get","node":{"key":"/hello","value":"world","modifiedIndex":1,"createdIndex":1}}
```

## Custom installation

You can customize your installation using an options file.

### DC/OS OpenSource

etcd has a feature called auto-tls. If this is enabled, etcd will create self-signed certificates on startup and use them to secure communication between cluster members (peers) and between clients and cluster members. Be advised that peer-authentication using certificates is not enabled with auto-tls.

To enable auto-tls create a `options.json` file with the following contents:

```json
{
  "etcd": {
    "tls_enabled": true,
    "use_auto_tls": true,
  }
}
```

Then install etcd using the following command: `dcos package install etcd --options=options.json`.
Once the cluster is installed you can access the API only via HTTPS (`https://api.etcd.l4lb.thisdcos.directory:2379`).


### DC/OS EE

If you want to enable TLS support you first need to create a serviceaccount:

```bash
dcos security org service-accounts keypair private-key.pem public-key.pem
dcos security org service-accounts create -p public-key.pem -d "etcd service account" etcd-principal
dcos security secrets create-sa-secret --strict private-key.pem etcd-principal etcd/principal
dcos security org groups add_user superusers etcd-principal
```

Then create a `options.json` file with the following contents:

```json
{
  "service": {
    "service_account_secret": "etcd/principal",
    "service_account": "etcd-principal"
  },
  "etcd": {
    "tls_enabled": true
  }
}
```

Then install etcd using the following command: `dcos package install etcd --options=options.json`.

Once the cluster is installed you can access the API only via HTTPS (`https://api.etcd.l4lb.thisdcos.directory:2379`). etcd uses certificates created and signed by the cluster-internal DC/OS CA. Communication between cluster members (peers) is secured so that only members with a valid certificate from the cluster-internal CA are allowed to connect. Connections via the HTTPS API are allowed for everyone but you must either add the CA root certificate to your truststore (see [DC/OS documentation](https://docs.mesosphere.com/latest/security/ent/tls-ssl/get-cert/) on how to retrieve it) or disable certificate checking (only do that for testing).


### Advanced configuration

There are a number of other options you can use to configure etcd (both for DC/OS OpenSource and EE):

* `service.virtual_network_enabled` and `service.virtual_network_name`: Configure overlay network for etcd
* `node.cpus`: Number of cores per etcd node. Depending on the load of your cluster you should adjust this. For low loads `0.5` is sufficient. Default is `1`.
* `node.mem`: Memory in MB per etcd node. Change this depending on the number of keys stored in your etcd cluster. Default is `256`.
* `node.disk`: Disk size in MB. Default is `100`.
* `node.disk_type`: For etcd installations with high loads you should change this to `MOUNT` (requires preconfigured volumes on your DC/OS agents) to give etcd its own disk.
* `etcd.heartbeat_interval`: Time (in milliseconds) of a heartbeat interval. Default is `100`.
* `etcd.election_timeout`: Time (in milliseconds) for an election to timeout. Default is `1000`.
* `etcd.snapshot_count`: Number of committed transactions to trigger a snapshot to disk. Increase this if you have a busy cluster. Default is `100000`.

For all configuration options see `dcos package describe etcd --config`.

### Reconfiguration

To change the configuration of etcd update your options file and then run `dcos etcd update start --options=options.json`. Be aware that during the update all the etcd nodes will be restarted one by one and there will be a short downtime when the current leader is restarted.

You can increase the number of nodes, but not decrease it to avoid data loss. Also enabling/disabling TLS on an already installed cluster is not supported. If you need to do that, take a backup of your data and reinstall etcd.

## Troubleshooting

### Handle node failure

etcd stores its data locally on the host system it is running on. The data will survive a restart. In the event of a host failure the etcd node running on that host is lost and must be replaced. To do this, just run:

```bash
dcos etcd pod replace <pod-name>  (e.g. etcd-2)
```

The new pod will automatically remove the old failed member from the etcd cluster and add itself as a new member. If you need to replace more than one node wait between replacements to give the cluster time to copy all data and stabilize itself.

etcd can recover from a failure as long as a majority of nodes remain operational (at most `(N-1)/2` failures). If you installed etcd with the default number of 3 nodes that means that one node can fail without loosing any data. If more nodes fail automatic recovery is not possible. You can try a manual recovery.

### Manually recover etcd cluster node

In case something goes wrong and the automatic recovery is not successful you can try to manually recover a node. See the [etcd Disaster recovery documentation](https://coreos.com/etcd/docs/latest/op-guide/recovery.html) for possible actions. To do this run the following commands (we assume the faulty node is `etcd-2`):

```bash
dcos etcd pod replace etcd-2
# wait till pod is starting
dcos etcd debug pod pause etcd-2
dcos task exec -it etcd-2-node bash
# do your repairs and add the node as a member to the etcd cluster
touch $MESOS_SANDBOX/etcd-data/initialized   # this file signals the framework that the node is already initialized and configured
exit
dcos etcd debug pod resume etcd-2
```

## Further Resources

* [etcd Documentation](https://etcd.readthedocs.io/en/latest/)
* [dcos-etcd github](https://github.com/MaibornWolff/dcos-etcd)  (open an issue there for bugs or feature requests)