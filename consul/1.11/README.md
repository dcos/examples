# How to use consul on DC/OS

[Consul](https://www.consul.io) is an open-source tool for service discovery and configuration. Using the DC/OS consul package you can install and manage a distributed and highly available cluster of consul nodes in your DC/OS cluster.

## Requirements
* DC/OS cluster running at least version 1.11
* For TLS support DC/OS Enterprise is required
* Installed and configured dcos cli
* At least 3 cores and 2 GB of RAM available in your cluster


## Quickstart

```bash
dcos package install consul
```
By default the package will install 3 nodes. Check the DC/OS UI to see if all of the nodes have been started.

Log into a node in your cluster (e.g. by using `dcos node ssh --master-proxy --leader`) and run the following to test the HTTP API of consul:
```bash
$ curl -X PUT http://api.consul.l4lb.thisdcos.directory:8500/v1/kv/foo -d bar
true
$ curl http://api.consul.l4lb.thisdcos.directory:8500/v1/kv/foo
[{"LockIndex":0,"Key":"foo","Flags":0,"Value":"YmFy","CreateIndex":1 ,"ModifyIndex":1}]
```

## Custom installation
You can customize your installation using an options file.

If you want to enable TLS support you need to provide a serviceaccount (only works on DC/OS EE):
```bash
dcos security org service-accounts keypair private-key.pem public-key.pem
dcos security org service-accounts create -p public-key.pem -d "Consul service account" consul-principal
dcos security secrets create-sa-secret --strict private-key.pem consul-principal consul/principal
dcos security org groups add_user superusers consul-principal
```

Then create a `options.json` file with the following contents:

```json
{
    "service": {
        "service_account_secret": "consul/principal",
        "service_account": "consul-principal"
    },
    "consul": {
        "security": {
            "gossip_encryption_key": "toEtMu3TSeQasOI2Zg/OVg==",
            "transport_encryption_enabled": true
        }
    }
}
```
For more configuration options see `dcos package describe consul --config`.


For any non-demo developments you must generate your own gossip encryption key. To do so download the consul binary from the [consul homepage](https://www.consul.io/downloads.html) and run `./consul keygen`. Add the output as value for `gossip_encryption_key`.

To install the customized configuration run `dcos package install consul --options=options.json`.

After the framework has been started you can reach the HTTPS API via `https://api-tls.consul.l4lb.thisdcos.directory:8501`. The endpoint uses certificates signed by the cluster-internal DC/OS CA. So you need to either provide the CA certificate to your clients (recommended, see [DC/OS documentation](https://docs.mesosphere.com/1.12/security/ent/tls-ssl/get-cert/) on how to retrive it) or disable certificate checking (only do that for testing).


## Change configuration
To change the configuration of consul update your options file and then run `dcos package update start --options=options.json`. Be aware that during the update all the consul nodes will be restarted one by one and there will be a short downtime when the current leader is restarted.

You can increase the number of nodes (check the [consul deployment table](https://www.consul.io/docs/internals/consensus.html#deployment-table) on recommended number of nodes), but not decrease it to avoid data loss.


## Expose Consul UI
Consul provides an internal UI. You can use it to see the current status of your consul cluster and also directly configure parts of it (for example you can create/edit/delete keys in the key-value-store).
To access the UI you need to expose it via your marathon-lb loadbalancer.

Create a file `consul-proxy.json` with the following content:
```json
{
  "id": "/consul-proxy",
  "cmd": "tail -F /dev/null",
  "instances": 1,
  "cpus": 0.01,
  "mem": 16,
  "portDefinitions": [
    { "port": 0, "protocol": "tcp"}
  ],
  "labels": {
    "HAPROXY_GROUP": "external",
    "HAPROXY_0_PORT": "8500",
    "HAPROXY_0_VHOST": "consul.mycorp",
    "HAPROXY_0_BACKEND_SERVER_OPTIONS": "  server consul api.consul.l4lb.thisdcos.directory:8500"
  },
  "networks": [
    {"mode": "host"}
  ],
  "requirePorts": false,
  "upgradeStrategy": {
    "maximumOverCapacity": 1,
    "minimumHealthCapacity": 1
  },
  "unreachableStrategy": {
   "inactiveAfterSeconds": 0,
   "expungeAfterSeconds": 0
  }
}
```

If you have TLS enabled change the port to `8501` and set the server options to `server consul api-tls.consul.l4lb.thisdcos.directory:8501 ssl verify none`. The vhost must be a dns name that is routed to your loadbalancer.
To install it run `dcos marathon app add consul-proxy.json`. Afterwards the consul UI is avilable under `http://consul.mycorp`. For any production installation you should secure the UI using basic auth and enforce HTTPS on the loadbalancer.


## Handle node failure
Consul stores its data locally on the host system it is running on. The data will survive a restart. In the event of a host failure the consul node running on that host is lost and must be replaced.
To do so execute the following steps:

* Find out which node is lost by running `dcos consul pod status`. Let's assume it is `consul-2`.
* Force-leave the failed node from consul by  running `dcos task exec -it consul-0-node ./consul force-leave <node-name>` (e.g. `dcos task exec -it consul-0-node ./consul force-leave consul-2-node`).
* Replace the failed pod: `dcos consul pod replace <pod-name>` (e.g. `dcos consul pod replace consul-2`).

If you replaced the pod without first executing the force-leave, the new node will join the cluster nonetheless, but all consul instances will report errors of the form
`Error while renaming Node ID: "f4ed39ca-3a00-4554-8d5e-e952488d670f": Node name consul-2-node is reserved by node 55921e76-a55b-5cf5-fc25-7936c57ce05d with name consul-2-node`.
To get rid of these errors, do the following (again assuming the pod in question is `consul-2`):

* `dcos consul debug pod pause consul-2`
* `dcos consul task exec -it consul-0-node ./consul force-leave consul-2-node`
* `dcos consul debug pod resume consul-2`

After this the new node will rejoin the cluster.

You should only replace one node at a time and wait between nodes to give the cluster time to stabilize.
Depending on your configured number of nodes consul will survive the loss of one or more nodes (for three nodes one node can be lost) and will remain operational.

## Further Resources

* [Consul Documentation](https://www.consul.io/docs/index.html)
* [dcos-consul github](https://github.com/MaibornWolff/dcos-consul)  (open an issue there for bugs or feature requests)