# How to use Apache Flink on DC/OS

[Apache Flink](https://flink.apache.org/) is an open source platform for distributed stream and batch data processing. Apache Flink comes with native Mesos support and can be also installed a DC/OS service

- Estimated time for completion: 5 minutes
- Target audience: Data engineers; basic knowledge of Apache Flink and DC/OS is helpful, but not required.
- Scope: Install and use Flink.

**Table of Contents**:

- [Prerequisites](#prerequisites)
- [Install Apache Flink](#install-flink)
- [Use Apache Flink](#use-flink)
- [Uninstall Apache Flink](#uninstall-flink)

## Prerequisites

- A running DC/OS 1.9 cluster with 1 agents with each 2 CPU and 2 GB of RAM available.
- [DC/OS CLI](https://dcos.io/docs/1.9/usage/cli/install/) installed.

## Install Flink

To install Apache Flink, do:

```bash
$ dcos package install flink
By Deploying, you agree to the Terms and Conditions https://mesosphere.com/catalog-terms-conditions/#community-services
This DC/OS Service is currently in preview. There may be bugs, incomplete features, incorrect documentation, or other discrepancies. Flink requires by default 2 CPUs with 2GB of RAM on private nodes.
Continue installing? [yes/no] yes
Installing Marathon app for package [flink] version [1.3.1-1.2-1.2]
Installing CLI subcommand for package [flink] version [1.3.1-1.2-1.2]
New command available: dcos flink
DC/OS Flink is being installed!

	Documentation: https://ci.apache.org/projects/flink/flink-docs-release-1.3/
```

After this, you should see the Flink service running via the `Services` tab of the DC/OS UI:

![Flink DC/OS service](img/services.png)


### Scala 2.11

Note, that the default build of Apache Flink and this universe package are both using Scala 2.10.

If you require Scala 2.11 please use the following install option from the UI (or via options.json when using the CLI):
![Scala 2.11](img/scala2_11.png)


## Use Flink

NOTE: In order to have better access to the input and output files, it makes sense to store those in HDFS.

### Upload Jar file via Flink UI
In the following we will use the DC/OS [Admin Router](https://dcos.io/docs/1.9/development/dcos-integration/#-a-name-adminrouter-a-admin-router) to provide access to the Flink UI: use the URL `http://$DCOS_DASHBOARD/service/flink/` and replace `$DCOS_DASHBOARD` with the URL of your DC/OS UI. Alternatively, you can also click `Open Service` in the DC/OS UI. The Flink dashboard UI looks like below.

![Flink Dashboard](img/dashboard.png)

Let us start our first job by going to `Submit new Job` in the Flink UI. We first need to add the respective jar file. For this example we will use the WordCount example jar file which can be found in `flink/build-target/examples/batch/WordCount.jar`.


### Run Jobs

#### Run Jobs via Flink UI

Next, we can define our job as shown below:

![Submit Flink Job](img/submit.png)

After the job has finished we should be able to see some details about the WordCount job:

![Finished Flink Job](img/finished.png)

#### Run Jobs via DC/OS Flink CLI

1. Submit the jar file via the CLI using `dcos flink upload`

```
$ dcos flink upload examples/WordCount.jar
http://m1.dcos/service/flink/jars/upload
{"status": "success", "filename": "c552ce76-ab00-48bf-8146-99d8c0114676_WordCount.jar"}
```

2. Find the jar id of the jar file that you wish to run using `dcos flink jars`

```
$ dcos flink jars
{
  "address": "http://a1.dcos:9149",
  "files": [
    {
      "id": "be38ffc9-dd6a-44dd-ae9f-449a3dcb39a4_WordCount.jar",
      "name": "WordCount.jar",
      "uploaded": 1508961041000,
      "entry": [
        {
          "name": "org.apache.flink.examples.java.wordcount.WordCount",
          "description": "No description provided"
        }
      ]
    },
    {
      "id": "c552ce76-ab00-48bf-8146-99d8c0114676_WordCount.jar",
      "name": "WordCount.jar",
      "uploaded": 1508961280000,
      "entry": [
        {
          "name": "org.apache.flink.examples.java.wordcount.WordCount",
          "description": "No description provided"
        }
      ]
    }
  ]
}
```

3. Call `dcos flink run <jar id>`
```
$ dcos flink run c552ce76-ab00-48bf-8146-99d8c0114676_WordCount.jar
{
  "jobid": "897bca2e8f6bbd99b9f217769dc6d149"
}

```
If successful, the terminal will return a job id.

4. To verify that the job has finished, call `dcos flink list`

```
$ dcos flink list
{
  "jobs-running": [],
  "jobs-finished": [
    "f483430a59f632b1ae9671e1883dd5db",
    "897bca2e8f6bbd99b9f217769dc6d149"
  ],
  "jobs-cancelled": [],
  "jobs-failed": []
}

```
Notice that our job has successfully finished.

## Uninstall Flink

To uninstall Flink:

```bash
$ dcos package uninstall flink
```
## Troubleshooting

### AWS Specific Config

There is a situation which can occur where the JobMaster is not able to resolve its hostname.  This causes the TaskManager container that launches to never communicate with the JobManager and the cluster never enters the ready state. 
In the logs will contain something similar to 

```
2017-07-29 17:10:05,553 ERROR org.apache.flink.mesos.runtime.clusterframework.MesosApplicationMasterRunner  - Mesos JobManager initialization failed
java.net.UnknownHostException: agentname: agentname: Name or service not known
    at java.net.InetAddress.getLocalHost(InetAddress.java:1505)
```

This can be resolved by [enabling "DNS Hostname" support in the VPC](https://www.ericmichaelstone.com/?p=7430) for the agents.

```
aws ec2 modify-vpc-attribute --vpc-id vpc-a01106c2 --enable-dns-hostnames "{\"Value\":true}"
```
