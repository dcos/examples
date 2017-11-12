# DC/OS Spinnaker Service Guide


# Overview

DC/OS Spinnaker is an automated service that makes it easy to deploy and manage [Spinnaker](https://www.spinnaker.io/) on [DC/OS](https://mesosphere.com/product/).

Spinnaker is an open source, multi-cloud continuous delivery platform for releasing software changes with high velocity and confidence.

Created at Netflix, it has been battle-tested in production by hundreds of teams over millions of deployments. It combines a powerful and flexible pipeline management system with integrations to the major cloud providers.

### Note
The DC/OS Spinnaker service currently only works with **DC/OS Enterprise**. See also the [release notes](docs/RELEASE_NOTES.md).



# Install

## Create DC/OS User
In the DC/OS console under Organization create a user to be used by Spinnaker to provision DC/OS services. The user has to have the following permissions. 

```
dcos:superuser
```

You will need the user name and password for the *clouddriver-local.yml* configuration in the following step.


## Prepare Spinnaker configuration

Use the following command to download Spinnaker configuration templates to get started.
```
curl -O https://s3-us-west-1.amazonaws.com/mbgl-bucket/spinnaker/assets/spin-config.zip && unzip spin-config.zip && cd config && chmod +x gen-configjson
```

You will have to tailor the Spinnaker yml configuration files for your specific needs.

**Note:** If you follow the links to the detailed Spinnaker configuration options you will also see the configuration of service dependencies. Don't worry about those configurations they are all taken care of by the DC/OS Spinnaker framework.


### [front50-local.yml](config/front50-local.yml)
Front50 is the Spinnaker **persistence service**. The file shows how to configure the AWS S3 (enabled=true) and GCS (enabled=false) persistence plugin.

For giving spinnaker a 1st spin on DC/OS you can use the S3 compatible minio service availble from the DC/OS catalog. Configure it to be available on port 9001 via the marathon-lb. The only addition that you need in the front50-local.yml is the specification of the S3 enpoint url shown in the following.
```
...
  s3:
    enabled: true
    bucket: <s3-bucket-name>
    rootFolder: <name-of-folder-in-the-s3-bucket>
    endpoint: http://marathon-lb.marathon.mesos:9001
...
```

In order to complete the front50 configuration you have to configure the following secrets in DC/OS. You have to create all of them, you create the ones you are not using with empty content.
```
dcos security secrets create -v <your-aws-access-key-id> spinnaker/aws_access_key_id

dcos security secrets create -v <your-aws-secret-access-key> spinnaker/aws_secret_access_key

dcos security secrets create -v <your-gcp-key> spinnaker/gcp_key
```

For more configuration options see [spinnaker/front50](https://github.com/spinnaker/front50/blob/master/front50-web/config/front50.yml), and [spinnaker/spinnaker](https://github.com/spinnaker/spinnaker/blob/master/config/front50.yml).


### [clouddriver-local.yml](config/clouddriver-local.yml)
Clouddriver is the Spinnaker **cloud provider service**. The file shows how to configure the DC/OS provider plugin.

For more configuration options see [spinnaker/clouddriver](https://github.com/spinnaker/clouddriver/blob/master/clouddriver-web/config/clouddriver.yml), and [spinnaker/spinnaker](https://github.com/spinnaker/spinnaker/blob/master/config/clouddriver.yml).


### [echo-local.yml](config/echo-local.yml) (optional)
Echo is the Spinnaker **notification service**. The file shows how to configure the email notification plugin.

For more configuration options see [spinnaker/echo](https://github.com/spinnaker/echo/blob/master/echo-web/config/echo.yml), and [spinnaker/spinnaker](https://github.com/spinnaker/spinnaker/blob/master/config/echo.yml).


### [igor-local.yml](config/igor-local.yml) (optional)
Igor is the Spinnaker **trigger service**. The file shows how to configure the dockerRegsitry trigger plugin.

For more configuration options see [spinnaker/igor](https://github.com/spinnaker/igor/blob/master/igor-web/config/igor.yml), and [spinnaker/spinnaker](https://github.com/spinnaker/spinnaker/blob/master/config/igor.yml).


### Create config.json file with gen-configjson
Once you are done with tailoring the Spinnaker yml configuration files use the following command in the config folder to produce the *config.json* file that we will have to pass on package install. Optional yml configuration files for which you dont want to specify content at this point should be removed from config folder.

```
./gen-configjson
```


## Install the Spinnaker service

```
dcos package install --yes spinnaker --options=<path>/config.json
```

## Install the Spinnaker proxy service

Create a proxy.json file with the following content. 

```
{
  "id": "spinnaker-proxy",
  "container": {
    "type": "DOCKER",
    "docker": {
      "image": "realmbgl/spinproxy",
      "forcePullImage": true
    }
  },
  "args": [],
  "cpus": 0.1,
  "mem": 256,
  "env": {
  },
  "instances": 1,
  "constraints": [],
  "acceptedResourceRoles": [
      "slave_public"
  ]
}
```

The proxy will run on the public agent and serve both the spinnaker user interface (deck service) and api (gate service).

Use the following command to launch the proxy.

```
dcos marathon app add proxy.json
```

Create the following ssh tunnels to the public agent.

```
ssh -i <private-key-file> -f core@<public-agent-ip> -L 9000:localhost:9000 -N
ssh -i <private-key-file> -f core@<public-agent-ip> -L 8084:localhost:8084 -N
```


# Update

## Update Spinnaker configuration
Update one or more of the Spinnaker yml configuration files. Once you are done use the following command to produce the updated *config.json* file that we will have to pass with the spinnaker update command.

```
./gen-configjson
```

## Update the Spinnaker service

```
dcos spinnaker --name=/spinnaker update start --options=<path>/config.json
```

# Using Spinnaker

Go to your browser and enter the following url to get to the spinnaker unser interface.

```
http://localhost:9000
```

Follow these links to learn more.
* [Spinnaker Apllications, Clusters, and Server Groups](docs/APPLICATIONS_CLUSTERS_SERVERGROUPS.md) 
* [Spinnaker Pipelines](docs/PIPELINES.md) 
* [DC/OS Enterprise Edge-LB](docs/EDGE_LB.md)

