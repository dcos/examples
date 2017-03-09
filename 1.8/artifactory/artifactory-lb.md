## How to set up Artifactory-lb on DC/OS

## Pre-requisites

- DC/OS 1.8 or later with at least one public agent
- [DC/OS CLI installed](https://dcos.io/docs/1.8/usage/cli/install/) and configured to use your cluster
- A running installation of [Artifactory Pro](artifactory-pro.md) or [Artifactory Enterprise](artifactory-enterprise.md) on DC/OS

## Setting up Artifactory-lb:

1. Create a new file called `artifactory-lb-options.json`, with the following content:

```
{
  "service": {
    "name": "artifactory-lb",
    "cpus": 1,
    "instances": 1,
    "mem": 1024,
    "bridge": false,
    "ssl": {
      "enabled": false,
      "ssl_key_path": "http://www.example.com/example.key",
      "ssl_cert_path": "http://www.example.com/example.crt"
    }
  },
  "artifactory": {
    "name": "artifactory"
  }
}
```

If you customised the name of Artifactory when installing it, please change `artifactory.name`.

2. Run this command to install Artifactory-lb:

```
dcos package install --options="artifactory-lb-options.json" artifactory-lb
```

##### Use pre populated API KEY in case you have changed artifactory password.

## Accessing Artifactory

To access Artifactory, navigate to the DC/OS public agent where Artifactory-lb is running:

![Artifactory UI](img/Artifactory_UI.png)

For instructions on how to use Artifactory as a Docker Registry, see [this guide](using-artifactory.md).
