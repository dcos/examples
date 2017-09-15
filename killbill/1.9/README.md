# How to use Kill Bill on DC/OS

[Kill Bill](https://killbill.io/) is the open-source subscription billing and payments platform.

**Table of Contents**:

- [Prerequisites](#prerequisites)
- [Install MySQL](#install-mysql)
- [Install Kill Bill](#install-kill-bill)
- [Next steps](#next-steps)

## Prerequisites

- A running DC/OS 1.9 cluster with at least 1 node with 1 CPU and 2 GB of RAM available.
- [DC/OS CLI](https://dcos.io/docs/1.9/usage/cli/install/) installed.

## Install MySQL

Create a file called `config.json` and set the following properties:

```json
{
  "service": {
    "name": "mysql"
  },
  "database": {
    "name": "killbill",
    "username": "killbill",
    "password": "killbill",
    "root_password": "root"
  },
  "networking": {
    "port": 3306,
    "host_mode": true
  }
}
```

Then, install MySQL:

```bash
dcos package install mysql --y --options=config.json
```

Finally, setup the DDL (replace `a1.dcos` with the hostname returned by `dcos task mysql`):

```bash
curl -s http://docs.killbill.io/0.18/ddl.sql | mysql -h a1.dcos -u root -proot killbill
```

## Install Marathon-LB

Create a file called `config.json` and set the following properties:

```json
{
  "marathon-lb":{
    "name":"marathon-lb-internal",
    "haproxy-group":"internal",
    "bind-http-https":false,
    "role":""
  }
}
```

Then, install Marathon-LB:

```bash
dcos package install marathon-lb --y --options=config.json
```

## Install Kill Bill

Create a file called `config.json` and set the following properties:

```json
{
  "database": {
    "host": "a1.dcos:3306",
    "name": "killbill",
    "user": "killbill",
    "password": "killbill"
  }
}
```

Then, install Kill Bill:

```bash
dcos package install killbill --yes --options=config.json
```

You can follow the installation process via:

```bash
dcos task log killbill --follow
```

Verify the installation was successful by visiting http://m1.dcos/service/killbill/1.0/healthcheck?pretty=true (replace `m1.dcos` with the hostname of your Marathon instance). Note: you need to be logged-in in Marathon.

Additionally, verify the integration with Marathon-lb by going to http://a1.dcos:9090/haproxy?stats (replace `a1.dcos` with the hostname returned by `dcos task marathon-lb-internal`). You should see entries for `killbill_10080`. Running `curl http://a1.dcos:10080/1.0/healthcheck` a few times should update the HAProxy stats. Kill Bill is now available in the cluster behind `marathon-lb-internal.marathon.mesos:10080`.

## Next steps

Documentation and tutorials can be found at http://docs.killbill.io/.
