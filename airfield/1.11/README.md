# Airfield

Airfield is an open source tool for the DC/OS ecosystem that enables teams to easily collaborate with shared [Apache Zeppelin](https://zeppelin.apache.org/) instances.

## Requirements

* DC/OS 1.11 or later
* Marathon-LB
* A wildcard DNS entry pointing at the loadbalancer. Each Zeppelin instance will be available using a random name as a subdomain of your wildcard domain. As an example we will be using `*.zeppelin.mycorp`.
* A Key-Value-Store to store the list of existing Zeppelin instances. Currently supported are either [consul](https://www.consul.io/) or [etcd](https://coreos.com/etcd/). If you have neither installed we recommend [consul](https://github.com/MaibornWolff/dcos-consul) which is available in the [universe](https://universe.dcos.io/#/package/consul/version/latest). Check the [consul example](../../consul/1.11/README.md) in this repo for details on how to install it.
* Enough available resources to run both Airfield and one Zeppelin instance (minimum: 3 cores, 10GB RAM).

## Installation

Before you start the installation make sure you have either consul or etcd installed and that the airfield vhost (`airfield.mycorp` in this example) and the wildcard domain (`*.zeppelin.mycorp` in this example) both have DNS entries that point to your marathon-lb instance.

Then depending on your cluster check the [DC/OS OpenSource](#dcos-opensource) or the [DC/OS EE](#dcos-ee) section for further instructions.

### DC/OS OpenSource


First create a file `options.json` (change values to fit your cluster):

```json
{
  "service": {
    "marathon_lb_vhost": "airfield.mycorp"
  },
  "airfield": {
    "marathon_lb_base_host": ".zeppelin.mycorp",
    "consul_endpoint": "http://api.aconsul.l4lb.thisdcos.directory:8500/v1",
    "dcos_base_url": "http://leader.mesos"
  }
}
```

Then you can install airfield using the following command:

```bash
dcos package install airfield --options=options.json
```

Wait for it to finish installing, then access airfield via the vhost you provided (`airfield.mycorp` in this example).


### DC/OS EE

First you need to create a serviceaccount for airfield to allow it access to the Marathon API (for starting the Zeppelin instances):

```bash
dcos security org service-accounts keypair private-key.pem public-key.pem
dcos security org service-accounts create -p public-key.pem -d "Airfield service account" airfield-principal
dcos security secrets create-sa-secret --strict private-key.pem airfield-principal airfield/account-secret
dcos security org groups add_user superusers airfield-principal
```

Then create a file `options.json` (change values to fit your cluster):

```json
{
  "service": {
    "marathon_lb_vhost": "airfield.mycorp",
    "service_account_secret": "airfield/account-secret"
  },
  "airfield": {
    "marathon_lb_base_host": ".zeppelin.mycorp",
    "consul_endpoint": "http://api.aconsul.l4lb.thisdcos.directory:8500/v1"
  }
}
```

Then you can install airfield using the following command:

```bash
dcos package install airfield --options=options.json
```

Wait for it to finish installing, then access airfield via the vhost you provided (`airfield.mycorp` in this example).

### Further configuration (OSS and EE)

With the following optional configuration parameters you can further customize your airfield installation:

* `airfield.etcd_endpoint` if you want to use etcd instead of consul, set it to `<dns_name>:<port>` (e.g. `api.etcd.l4lb.thisdcos.directory:2379`). Only one of `etcd_endpoint` or `consul_endpoint` should be present in your options.
* `airfield.app_group` if you want airfield to put the Zeppelin instances into a different marathon app group, the default is `airfield-zeppelin`.
* `airfield.config_base_key` if you want airfield to use a different key prefix for consul/etcd, the default is `airfield`.
* `service.virtual_network_enabled` and `service.virtual_network_name` if you want to run airfield in a virtual network.

For all available options see `dcos package describe airfield --config`.

## Usage

On first accessing airfield you will be greeted by the overview page.

![Airfield Overview](img/overview01.png)

The list is empty as no instances have been created yet. To do so, click the `Add instance` button on the top right side. In the dialog that follows you must select an instance size on the left (go with `Small` for your first instance).

![Create](img/create01.png)

On the right side you can change the preconfigured defaults to better fit your needs. If you want to use python or R you can install additional libraries via the `Libraries` tab. In the screenshot below we have added the python-requests library.

![Create](img/create02.png)

Once you are satisfied with the configuration click on `Create new instance`. Then go back to the overview by clicking on the airfield logo on the top left side. There you can now see your newly created Zeppelin instance. Wait a few minutes until the instance is running (use the refresh button on the right to check the status, the first instances will take longer to start because DC/OS has to pull the Zeppelin docker image which is quite big).

![Airfield Overview](img/overview02.png)

Once the Zeppelin instance is running click on the provided link to open it. You can now use Zeppelin however you like. As a starting point you can use the [Zeppelin Example](../../zeppelin/1.11/README.md) in this repo.

If you no longer need your instance you can either stop it (and start it again later) or delete it from the airfield overview page.

Please be aware that the Zeppelin instances have no persistent storage. That means if you restart, stop or delete an instance all notebook data will be lost. So you need to export you notebooks before that.