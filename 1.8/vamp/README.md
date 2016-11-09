# How to use Vamp on DC/OS 

[Vamp](http://www.vamp.io) is a microservices management platform for doing advanced canary releases and A/B testing.

- Estimated time for completion: 10 minutes
- Target audience: Anyone hosting web applications in microservices
- Scope: Install the DC/OS Vamp service


## Prerequisites

- A running DC/OS 1.8 cluster
- [DC/OS CLI](https://dcos.io/docs/1.8/usage/cli/install/) installed
- Elasticsearch cluster for Vamp to store data in

## Install Elasticsearch

You need Elasticsearch running in order to properly deploy Vamp. For testing purposes you can deploy our own image. For this, create a file called `elasticsearch.json` with this content:

```json
{
  "id": "elasticsearch",
  "instances": 1,
  "cpus": 0.2,
  "mem": 1024.0,
  "container": {
    "docker": {
      "image": "magneticio/elastic:2.2",
      "network": "HOST",
      "forcePullImage": true
    }
  }
}
```

Deploy it in your DC/OS cluster:

```bash
$ dcos marathon app add ./elasticsearch.json
Created deployment 376e2b36-7d44-44fe-9832-e9c0b2ce3689
```

**Be aware:** This image is not designed for production scale deployments, only for testing and demonstration purposes! 


## Install Vamp

To specify the connection details to Elasticsearch create a file called `vamp-config.json` with the following content:

```json
{
  "service": {
    "elasticsearch-url": "http://elasticsearch.marathon.mesos:9200",
    "logstash": "elasticsearch.marathon.mesos"
  }
}
```

Then, from the command line run the following:

```bash
$ dcos package install --options=vamp-config.json vamp
In order to run Vamp you need to specify connection parameters to Elasticsearch and Logstash.
See installation instruction at http://vamp.io/documentation/installation/dcos/

Continue installing? [yes/no] yes
Installing Marathon app for package [vamp] version [0.9.1-0.0.2]
Vamp has been successfully installed!

    Documentation: http://www.vamp.io
    Issues: https://github.com/magneticio/vamp/issues
```

Next, validate that Vamp is successfully installed. Go to the `Services` tab of the DC/OS UI and check if Vamp shows up in the list as `Healthy`:

![Services](img/services.png)

In addition, run this command to view installed services:

```bash
$ dcos package list
NAME  VERSION      APP         COMMAND  DESCRIPTION                                             
vamp  0.9.1-0.0.2  /vamp/vamp  ---      Canary test/release and autoscaling platform for DC/OS  

```


## Uninstall Vamp

To uninstall Vamp enter the following command:

```bash
$ dcos package uninstall vamp
```

Finally, to get rid of all traces of Vamp in ZooKeeper, follow the steps outlined in the [framework cleaner](https://docs.mesosphere.com/1.8/usage/managing-services/uninstall/#framework-cleaner).


## Further reading

For more information about Vamp check out our website at [www.vamp.io](http://www.vamp.io) where we have [tutorials](http://vamp.io/documentation/tutorials/) you can follow, or just read through the [documentation](http://vamp.io/documentation/how-vamp-works/architecture-and-components/).
