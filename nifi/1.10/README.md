# How to use Apache Nifi on DC/OS

[Nifi](http://nifi.apache.org) is an easy to use, powerful, and reliable system to process and distribute data.
Running Apache Nifi on DC/OS allows you to manage your data flow very easily. Saving data on HDFS or consuming data from Kafka will be easily scalable.

- Estimated time for completion: 5 minutes
- Target audience: Data engineers
- Scope: Install and use Apache Nifi.

**Table of Contents**:

- [Prerequisites](#prerequisites)
- [Install Nifi](#install-nifi)
- [Use Nifi](#use-nifi)
- [Example of Usage](#example-of-usage)
- [Uninstall Nifi](#uninstall-nifi)

## Prerequisites

- A running DC/OS 1.10 cluster with at least 1 private node and 1 public node.
- [DC/OS CLI](https://dcos.io/docs/1.10/usage/cli/install/) installed.
- Marathon-LB installed and running


## Install Nifi


```bash
$ dcos package install nifi
By Deploying, you agree to the Terms and Conditions https://mesosphere.com/catalog-terms-conditions/#community-services
This DC/OS Service is currently in preview. There may be bugs, incomplete features, incorrect documentation, or other discrepancies. Experimental packages should never be used in production!
Continue installing? [yes/no] yes
Installing Marathon app for package [nifi] version [1.1.1-0.1]
Nifi has been successfully installed and is accessible through Marathon-LB.
Documentation can be found at https://nifi.apache.org/docs.html
Please keep in mind that first start of nifi can take a more than 60 seconds, so please be patient. If you selected single node installation please add /nifi at the end of URL, ex.: http://NIFI_ENDOPOINT:PORT/nifi
```

After this, you should see the Nifi service running via the `Services` tab of the DC/OS UI:

![Nifi DC/OS service](img/services.png)


## Use Nifi

You typically want to access Nifi via a web browser outside of the DC/OS cluster. To access the Apache Nifi UI from outside of the DC/OS cluster you can use [Marathon-LB](https://dcos.io/docs/1.10/usage/service-discovery/marathon-lb/).

Please make sure that Marathon-LB is installed and running correctly in your cluster before trying to access Nifi.

Once Nifi is installed and running, please navigate to http://$YOUR_PUBLIC_NODE_IP_ADDRESS:9090/haproxy?stats and find out which port can be used for accessing Nifi .

## Example of Usage

Let's try to create a first flow in our new instance of Nifi.
We first drag a **Processor** onto the graph. When we do this, we are given the option of choosing many different types of Processors.

![List of the processors](img/processors.gif)

Ok, so as you can see this list is pretty huge! We can try to read some data from Kafka topic. To do that we need to choose processor called **ConsumeKafka** or **ConsumeKafka__0__10** (depends on your kafka version).

![choosing consumeKakfa processor](img/kafka-processor.gif)

In the properties tab we need to fill at least those bolded fields. The most interesting for us are:

- **Kafka Brokers** - list of the kafka brokers. If you are using kafka from DC/OS please take a look at the [Kafka Documentation](https://docs.mesosphere.com/service-docs/kafka/) to check how to determine it.
- **Topic Names** - list of the topics to consume, separated by comma.
- **Group Id** - that value is used to identify consumers that are within the same consumer group.

First processor is ready. Now, when we have the data we can try to send it to another destination like Elasticsearch.
Please choose a new processor called **PutElasticsearchHttp**.


![PutElasticsearchHttp properties](img/elk-properties.png)

After completing all required fields, your flow should look like this:

![flow](img/flow.png)

Now we have to connect them and run:

![flow](img/flow-end.gif)



## Uninstall Nifi

To uninstall Nifi:

```bash
$ dcos package uninstall nifi
```

## Further resources

1. [Nifi docs](https://nifi.apache.org/docs.html)
