# Running Riak on DC/OS


Riak is a distributed, highly-available key/value store, available in two main flavours:
 - Riak KV: a distributed NoSQL database ([Riak KV documentation](http://docs.basho.com/riak/kv/2.2.0/))
 - Riak TS: a distributed NoSQL key/value store optimized for time series data ([Riak TS documentation](http://docs.basho.com/riak/ts/1.5.1/))

-----------

## Contents

- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
- [Creating a Riak cluster](#creating-a-riak-cluster)
- [Inspecting Nodes](#inspecting-nodes)
- [Install the Director](#install-the-director)
- [Add Some Data](#add-some-data)
- [Uninstalling Riak](#uninstalling-riak)
- [Further Reading](#further-reading)


-------------
## Requirements


Before getting started with Riak on DC/OS, there are some recommendations you should consider:

-  A running DC/OS 1.8 cluster, with multiple agent nodes
-  Riak is a distributed data store: at least 5 nodes are recommended
-  Each node should have at least 16GB memory and 8.0 CPU for Dev/Test environments, or 32GB and 16.0 CPU for Production deployments


------------------

## Installation

Riak is available in the DC/OS Universe, and can be installed as follows:

		dcos package install riak [--options path/to/options.json]

By default (i.e. without passing `--options options.json`), the Riak framework expects the recommended minimum resources per node: 16GB mem, 8.0 CPU. It also ensures that each node is placed on a unique DCOS agent. If you wish to change any of these default values, you can do so by passing an options file that looks like this:

```
{
    "riak": {
        "node": {
            "cpus": 16.0,
            "mem": 32768.0
        }
    }
}
```

Depending on your network, installating may take a few moments. You can wait for the framework to start by running:

```
$ dcos riak framework wait-for-service --timeout 1200 # Prepare to wait up to 1200s
```

This will return as soon as the framework is available.

------------------

## Usage

Try executing `dcos riak`, or `dcos riak --help` to output the usage instructions like so:

```
dcos riak --help

Usage: dcos riak [OPTIONS] COMMAND [ARGS]...

  Command line utility for the Riak Mesos Framework / DCOS Service. This
  utility provides tools for modifying and accessing your Riak on Mesos
  installation.

Options:
  --home DIRECTORY  Changes the folder to operate on.
  --config PATH     Path to JSON configuration file.
  -v, --verbose     Enables verbose mode.
  --debug           Enables very verbose / debug mode.
  --info            Display information.
  --version         Display version.
  --config-schema   Display config schema.
  --framework TEXT  Changes the framework instance to operate on.
  --json            Enables json output.
  --insecure-ssl    Turns SSL verification off on HTTP requests
  --help            Show this message and exit.

Commands:
  cluster    Interact with Riak clusters
  config     Interact with configuration.
  director   Interact with an instance of Riak Mesos...
  framework  Interact with an instance of Riak Mesos...
  node       Interact with a Riak node
```

To get information about a sub-command, try `dcos riak <command> --help`:

```
dcos riak cluster --help
Usage: dcos riak cluster [OPTIONS] COMMAND [ARGS]...

  Interact with Riak clusters

...

Commands:
  add-node          Adds one or more (using --nodes) nodes.
  config            Gets or sets the riak.conf configuration for...
  config-advanced   Gets or sets the advanced.config...
  create            Creates a new cluster.
  destroy           Destroys a cluster.
  endpoints         Iterates over all nodes in cluster and prints...
  info              Gets current metadata about a cluster.
  list              Retrieves a list of clusters
  restart           Performs a rolling restart on a cluster.
  set               Sets list of clusters
  wait-for-service  Iterates over all nodes in cluster and...
```

------------------

## Creating a Riak cluster

Let's start with a 3 node cluster. First check if any clusters have already been created, and check available Riak versions:

    $ dcos riak cluster list
	{"clusters"[]}
    $ dcos riak config riak-versions | python -m json.tool
	{
	  "riak_versions": {
		"riak-kv-2-2": "https://github.com/basho-labs/riak-mesos/releases/download/2.0.0/riak-2.2.0-centos-7.tar.gz",
		"riak-ts-1-5": "https://github.com/basho-labs/riak-mesos/releases/download/2.0.0/riak_ts-1.5.1-centos-7.tar.gz"
	  }
	}

Create the cluster object in the RMF metadata, and then instruct the scheduler to create 3 Riak nodes:

    dcos riak cluster create ts riak-ts-1-5
    dcos riak cluster add-node ts --nodes 3
    dcos riak cluster list

NB: If you do not have enough DC/OS agents with sufficient resources to spare, the Framework cannot start all the nodes. This will be noted in the service logs, accessible via the DC/OS web UI:

    Dashboard -> 'riak' Service -> Current 'riak' task (e.g. 'riak.814402cc-e2fd-11e6-871a-70b3d5800001') -> Logs -> stdout

After a few moments, we can verify that individual nodes are ready for service with:

    dcos riak node wait-for-service riak-ts-1
    dcos riak node wait-for-service riak-ts-2
    dcos riak node wait-for-service riak-ts-3

Alternatively a shortcut to the above is:

    dcos riak cluster wait-for-service ts

To get connection information about each of the nodes directly, try this command:

    dcos riak cluster endpoints ts | python -m json.tool

The output should look similar to this:

```
{
    "riak-ts-1": {
        "alive": true,
        "http_direct": "mesos-agent-1.com:31716",
        "pb_direct": "mesos-agent-1.com:31717",
        "status": "started"
    },
    "riak-ts-2": {
        "alive": true,
        "http_direct": "mesos-agent-2.com:31589",
        "pb_direct": "mesos-agent-2.com:31590",
        "status": "started"
    },
    "riak-ts-3": {
        "alive": true,
        "http_direct": "mesos-agent-3.com:31491",
        "pb_direct": "mesos-agent-3.com:31492",
        "status": "started"
    }
}
```

----------------

## Inspecting Nodes

Now that the cluster is running, let's perform some checks on individual nodes. This first command will show the hostname and ports for http and protobufs, as well as the metadata stored by the RMF:

    dcos riak node info riak-ts-1

To get the current ring membership and partition ownership information for a node, try:

    dcos riak node status riak-ts-1 | python -m json.tool

The output of that command should yield results similar to the following if everything went well:

``` sourceCode
{
    "down": 0,
    "exiting": 0,
    "joining": 0,
    "leaving": 0,
    "nodes": [
        {
            "id": "riak-ts-1@ubuntu.local",
            "pending_percentage": null,
            "ring_percentage": 32.8125,
            "status": "valid"
        },
        {
            "id":  "riak-ts-2@ubuntu.local",
            "pending_percentage": null,
            "ring_percentage": 32.8125,
            "status": "valid"
        },
        {
            "id": "riak-ts-3@ubuntu.local",
            "pending_percentage": null,
            "ring_percentage": 34.375,
            "status": "valid"
        }
    ],
    "valid": 3
}
```

Other useful information can be found by executing these commands:

    dcos riak node aae-status riak-ts-1
    dcos riak node ringready riak-ts-1
    dcos riak node transfers riak-ts-1

-----------------

## Install the Director

There are a few ways to access the Riak nodes in your cluster, including hosting your own HAProxy and keeping the config updated to include the host names and ports for all of the nodes. This approach can be problematic because the HAProxy config would need to be updated every time there is a change to one of the nodes in the cluster resulting from restarts, task failures, etc.

To account for this difficulty, we've created a smart proxy called the `riak-mesos-director`. The director should keep tabs on the current state of the cluster including all of the hostnames and ports, and it also provides a load balancer / proxy to spread load across all of the nodes.

To install the director as a marathon app with an id that matches your configured cluster name + `-director`, simply run:

    dcos riak director install ts

-------------

## Add Some Data

Assuming that the director is now running, we can now find an endpoint to talk to Riak with this command:

    dcos riak director endpoints ts

The output should look similar to this:

```
{
    "cluster": "ts",
    "director_http": "mesos-agent-4.com:31694",
    "framework": "riak",
    "riak_http": "mesos-agent-4.com:31692",
    "riak_pb": "mesos-agent-4.com:31693"
}
```

Let's write a few keys to the cluster using the director:

    RIAK_HTTP=$(dcos riak director endpoints ts | python -c 'import sys, json; print json.load(sys.stdin)["riak_http"]')
    curl -XPUT $RIAK_HTTP/buckets/test/keys/one -d "this is data"
    curl -XPUT $RIAK_HTTP/buckets/test/keys/two -d "this is data too"


--------------

## Uninstalling Riak

In order to remove the package from your DC/OS cluster, simply run

    dcos package uninstall riak


--------------

## Further Reading

For full, detailed usage information on managing and running Riak clusters in DC/OS & Mesos, please see our [README](https://github.com/basho-labs/riak-mesos-tools/tree/2.0.0#usage). For support, please reach out to us via [Github issues](https://github.com/basho-labs/riak-mesos/issues/new)
