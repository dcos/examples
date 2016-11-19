# How to use Nexus 3 repository manager on DC/OS

[Nexus 3](http://www.sonatype.org/nexus/) is a repository manager that supports a broad variety of package managers, namely Bower, Docker, Maven 2, npm, NuGet, PyPI, and Raw site repositories. DC/OS allows you to quickly configure, install and manage NGINX.

- Estimated time for completion: 10 minutes
- Target audience: Anyone interested in running a repository manager.
- Scope: Learn how to install Nexus 3 on DC/OS

## Prerequisites

- A running DC/OS 1.8 cluster with at least 1 node having at least 0.5 CPUs and 2 GB of RAM available.
- [DC/OS CLI](https://dcos.io/docs/1.8/usage/cli/install/) installed.

## Install Nexus 3

Assuming you have a DC/OS cluster up and running, we will discuss the installation of Nexus 3 in two variants for persistence. One will be with host volumes, and the other with external persisten volumes. The reason behind that is that the data of the repository / the artifacts need to persisted, so that the Nexus 3 application can be restarted without a data loss. 

If you opt to use host volumes, make sure that there is a backup process in place, which will backup the data in the *data folder*, or that you use a shared filesystem mount (such as NFS) for it.

### Host volumes

Let's get started by creating a file called `options.json` with following contents:

```json
{
  "service": {
    "name": "nexus",
    "cpus": 1,
    "mem": 2048,
    "role": "*",
    "local-volumes": {
      "host-volume": "/opt/nexus",
      "pinned-hostname": "192.168.200.101"
    },
    "external-volumes": {
      "enabled": false
    }
  },
  "networking": {
    "virtual-host": "nexus.dcos.mydomain.mytld"
  }
}
```

The above `options.json` file configures Nexus 3 as follows:

- `name`: This parameter configures the name of the service itself.
- `cpus`: This parameter configures the number of CPU share to allocate to Nexus 3.
- `mem`: This parameter configures the amount of RAM to allocate to Nexus 3.
- `role`: The role which should be used to launch the service. Default is `*`.
- `local-volumes`: This parameter configures whether service should use local host volumes. If so, the following properties need to be defined as well:
 - `host-volume`: This is the folder/path which will be mounted in the container, and used to persist the Nexus 3 data on. You need to make sure that the folder exists on the host you used for host pinning, and that it has the appropriate permissions/ownership. You can find a short guide below.
 - `pinned-hostname`: The hostname (or IP address) which should be used to run Nexus 3 on. This is important, because the `host-volume` folder needs to exist on that host (see above). Replace the value with an actual agent IP address.
- `networking`: Use this if you want your Nexus 3 service to be available externally.
 - `virtual-host`: Specify the CNAME (or FQDN) of your edge loadbalancer of the DC/OS cluster to be used to expose the service on.

**Creating the host volume**

To create the host volume, you have to ssh into the host where you want to run the Nexus 3 service on (via host pinning). Then, you should create a folder for the Nexus 3 data. Once you did this, you need to change the ownership of the respective folder to `200:200`. 

See the example below:

```bash
$ ssh user@hostname

hostname $ mkdir -p /opt/nexus

hostname $ chown -R 200:200 /opt/nexus
```

### External persistent volumes

```json
{
  "service": {
    "name": "nexus",
    "cpus": 1,
    "mem": 2048,
    "role": "*",
    "local-volumes": {},
    "external-volumes": {
      "enabled": true
    }
  },
  "networking": {
    "virtual-host": "nexus.dcos.mydomain.mytld"
  }
}
```

The above `options.json` file configures Nexus 3 as follows:

- `name`: This parameter configures the name of the service itself.
- `cpus`: This parameter configures the number of CPU share to allocate to Nexus 3.
- `mem`: This parameter configures the amount of RAM to allocate to Nexus 3.
- `role`: The role which should be used to launch the service. Default is `*`.
- `local-volumes`: Can be left blank if using external persistent volumes.
- `external-volumes`: This parameter configures whether service should use external persistent volumes. If so, the following property need to be defined as well:
 - `enabled`: Signals that external persistent volumes should be used.
- `networking`: Use this if you want your Nexus 3 service to be available externally.
 - `virtual-host`: Specify the CNAME (or FQDN) of your edge loadbalancer of the DC/OS cluster to be used to expose the service on.

## Usage

If you defined `networking.virtual-host` you should be able to access Nexus 3 on the URL you specified there. Otherwise, you can access it from inside the DC/OS via `http://nexus.marathon.mesos:<hostPort>`, where the `hostPort` can be found under the Nexus task's details under the Services tab of the DC/OS UI. 

The initial username/password combination to log in is `admin` and `admin123`.

For further documentation on how to use Nexus 3, please refer to the [docs](http://books.sonatype.com/nexus-book/index.html).