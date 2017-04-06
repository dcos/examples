# How to use Apache Storm on DC/OS

[Apache Storm](http://storm.apache.org) is a distributed realtime computation system.
The [DC/OS Storm](https://github.com/mesos/storm) service is a Mesos framework that allows you to manage
and use Storm in a flexible and scalable way.

- Estimated time for completion: 5 minutes
- Target audience: Data engineers and data scientists a stream processing engine.
- Scope: Install and use Apache Storm.

**Table of Contents**:

- [Prerequisites](#prerequisites)
- [Install Storm](#install-storm)
- [Use Storm](#use-storm)
- [Uninstall Storm](#uninstall-storm)

## Prerequisites

- A running DC/OS 1.8 cluster with 2 agents with each 1 CPU and 1 GB of RAM available.
- [DC/OS CLI](https://dcos.io/docs/1.8/usage/cli/install/) installed.

## Install Storm

To install Storm, do:

```bash
$ dcos package install storm
Note that the Apache Storm DCOS Service is beta and there may be bugs, incomplete features, incorrect documentation or other discrepancies.
Continue installing? [yes/no] yes
Installing Marathon app for package [storm] version [0.1.0]
Package is already installed
```

After this, you should see the Storm service running via the `Services` tab of the DC/OS UI:

![Storm DC/OS service](img/services.png)

## Use Storm

To use Storm, we will use a DC/OS CLI extension called [tunnel](https://dcos.io/docs/1.8/administration/access-node/tunnel/), effectively allowing us to create a VPN to access the Storm UI running inside the DC/OS cluster.

Now, once you've `dcos tunnel` set up and created a VPN tunnel you should see something like the following (in the example here we're using OpenVPN):

```bash
 $ sudo dcos tunnel vpn --client=/Applications/Tunnelblick.app/Contents/Resources/openvpn/openvpn-2.3.12/openvpn
Password:
*** Unknown ssh-rsa host key for 52.50.225.76: 1565ae7d574857729b625205416eae1e

ATTENTION: IF DNS DOESN'T WORK, add these DNS servers!
198.51.100.1
198.51.100.2
198.51.100.3

Waiting for VPN server in container 'openvpn-28frfq1q' to come up...

VPN server output at /tmp/tmp_62teeyl
VPN client output at /tmp/tmpbm3_w8wp
```

When the VPN is up you can access cluster services directly from you local environment (try for example `curl leader.mesos`) you can access the Storm UI via the following URL: 

```
http://storm.mesos:$UI_PORT/index.html
```

With `$UI_PORT` being the first port assigned to the Storm service by the System Marathon. Note that you can either look up that port via the `Services` tab or directly using a DC/OS CLI command like the following:

```bash
$ dcos marathon app show /storm | grep -A 30 tasks | grep -A 2 ports
      "ports": [
        11585,
        11586
```

So in our example case the value for `$UI_PORT` (`ui.port` in the Storm config) would be `11585`. Note also that the second value you see here, `11586`, is `nimbus.thrift.port`.

## Uninstall Storm

To uninstall Storm:

```bash
$ dcos package uninstall storm
```

## Further resources

1. [DC/OS Storm Official Documentation](https://github.com/mesos/storm)
1. [Apache Storm 1.0.1 docs](http://storm.apache.org/releases/1.0.1/)


