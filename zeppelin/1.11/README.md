# How to use Apache Zeppelin on DC/OS

[Apache Zeppelin](https://zeppelin.apache.org/) is a web-based notebook that enables you to do interactive data analytics. For example, you can use it as a front-end for [Apache Spark](https://github.com/dcos/examples/tree/master/1.8/spark).

- Estimated time for completion: 8 minutes
- Target audience: Data scientists and data engineers that want an interactive data analytics tool.
- Scope: Install and use Zeppelin in DC/OS.

**Table of Contents**:

- [Prerequisites](#prerequisites)
- [Install Zeppelin](#install-zeppelin)
- [Use Zeppelin](#use-zeppelin)
- [Uninstall Zeppelin](#uninstall-zeppelin)

## Prerequisites

- A running DC/OS 1.11 cluster with 2 agents (one private, one public) each with 2 CPUs and 2 GB of RAM available.
- [DC/OS CLI](https://docs.mesosphere.com/1.11/cli/install/) installed.
- [Marathon-LB](https://docs.mesosphere.com/services/marathon-lb/) installed.

## Install Zeppelin

You typically want to access Zeppelin via a web browser outside of the DC/OS cluster. To access the Zeppelin UI from outside of the DC/OS cluster you can use Marathon-LB, which is recommended for production usage. The following steps will install zeppelin: 

```bash
$ dcos package install zeppelin
This DC/OS Service is currently in preview.
Continue installing? [yes/no] yes
Installing Marathon app for package [zeppelin] version [0.7.3-2.2.1]
DC/OS Zeppelin is being installed!

	Documentation:  https://github.com/dcos/examples/tree/master/zeppelin/1.11
	Issues: https://dcos.io/community or
		 	https://github.com/MaibornWolff/dcos-zeppelin
```

After this, you should see the Zeppelin service running via the `Services` tab of the DC/OS UI:

![Zeppelin DC/OS service](img/services.png)

## Use Zeppelin

In the DC/OS UI, clicking on the `Open Service` button in the right upper corner leads to the Zeppelin UI:

![Zeppelin UI](img/zeppelin-ui.png)

To get started with Zeppelin you can create a new Notebook and paste the following Spark snippet in Scala:

```
val rdd = sc.parallelize(1 to 5)
rdd.sum()
```
After you've pressed the `Run all paragraphs` button (the triangle/play button in the menu), you should see something like the following

![Zeppelin simple Spark Scala snippet](img/zeppelin-spark-scala.png)

Next, you can check out the built-in tutorial in form of a Notebook called [Zeppelin Tutorial](http://zeppelin.apache.org/docs/0.7.3/quickstart/tutorial.html):

![Zeppelin Tutorial](img/zeppelin-tutorial.png)

## Uninstall Zeppelin

To uninstall Zeppelin:

```bash
$ dcos package uninstall zeppelin
```

## Further resources

1. [Zeppelin docs](http://zeppelin.apache.org/docs/0.7.3/)


