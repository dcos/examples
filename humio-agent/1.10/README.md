# How to use Humio Agent on DC/OS

[Humio](https://humio.com/?utm_source=DCOSUniverse&utm_medium=docs&utm_campaign=doc) is the next generation log management tool, making it possible to collect terabytes of logs each day and make them available in realtime.

DC/OS makes it very easy to deploy Humio across all Mesos agent nodes (including public) in the cluster, and also configures the Humio Agents to automatically collect Mesos task logs.

* Estimated time for completion: 10 minutes
* Target audience: Development and Ops teams
* Scope: 
    * [Prerequisites](#prerequisites)
    * [Install Humio Agent](#install-humio-agent)
    * [Access Humio](#access-humio)

## Prerequisites

- A Humio account with one dataspace
- A running DC/OS 1.10 cluster with at least 1 node and at least 1 CPUs and 1 GB of RAM available.

## Install Humio Agent

To install the Humio Agent, login to DC/OS and go to the Catalog tab. Select
humio-agent and and then click on configure button. You will be presented
with a list of options.

Your first option will be what Humio host to use. If you signed up for at free account on [humio.com](https://humio.com/?utm_source=DCOSUniverse&utm_medium=docs&utm_campaign=doc), your Humio host will be `go.humio.com`.

Second is the dataspace. Open up the humio you provided in the Humio host above to see your list of dataspaces. If you haven't created one yet, you'll have to do that first. Fill in the name of the dataspace in the Dataspace field.

Last you'll need a ingest token. Ingest token can be created on your Humio host, under settings, under Ingest Tokens. We recommend creating a new one for every deployment.

After all options are configured, press Review and Deploy and then Deploy to set up humio-agent. Please note that it may take up to 10 minutes for the humio-agent to start forwarding your task logs.

Last but not least, to check if the agent is running, use the DC/OS UI where in the `Services` tab you should see the Humio Agent service and an agent for each node listed with their statuses as "Running".

## Access Humio

Once you've installed the Humio Agent as outlined above, navigate to the service instance in the DC/OS ui and choose Open Service which should bring you to the Humio dataspace overview page.

All logs are conveniently tagged with the following keys
- `mesos_slave_id`
- `mesos_framework_id`
- `mesos_framework_name`
- `mesos_task_id` 
- `dcos_space`

To get started you can make a search for `groupby(mesos_task_id)` which should give you a list of recently logging tasks.
For more information about query language take a look at our [Online tutorial](https://go.humio.com/docs/tutorial/index.html?utm_source=DCOSUniverse&utm_medium=docs&utm_campaign=doc)

## Configuring task logs

All application logs are different so the the types of the logs can be controlled with a `HUMIO_TYPE` label on the task. The value of the label will be put into the `#type` field when sent to Humio.
See [Parsing logs](https://go.humio.com/docs/parsing/index.html?utm_source=DCOSUniverse&utm_medium=docs&utm_campaign=doc) for more information on how to choose a log type and create your own parser

To ignore a log you can add `HUMIO_IGNORE` label with the value `true` to your task to skip logs.

For more information on how to configure your task take a look at the [Humio documentation](https://go.humio.com/docs?utm_source=DCOSUniverse&utm_medium=docs&utm_campaign=doc)