# Setting up Artifactory-lb on DC/OS

## Prerequisites

- DC/OS 1.10 or later with at least one public agent
- [DC/OS CLI installed](https://dcos.io/docs/1.10/usage/cli/install/) and
  configured to use your cluster
- A running installation of [Artifactory Pro](artifactory-pro.md) or
  [Artifactory Enterprise](artifactory-enterprise.md) on DC/OS

## Setting up Artifactory-lb:

1. Create a new file called `artifactory-lb-options.json`, with the following
   content:

```
{
  "service": {
    "name": "artifactory-lb"
  },
  "artifactory": {
    "name": "artifactory"
  }
}
```

If you customised the name of Artifactory when installing it, please change
`artifactory.name`.

2. Run this command to install Artifactory-lb:

```
dcos package install --options=artifactory-lb-options.json artifactory-lb
```

## Accessing Artifactory

To access Artifactory, navigate to the DC/OS public agent where Artifactory-lb
is running:

![Artifactory UI](img/Artifactory_UI.png)

If you're using the Amazon CloudFormation DC/OS templates, you will need to
[find the hostname or IP address of the specific public
agent](https://dcos.io/docs/1.10/administering-clusters/locate-public-agent/)
where Artifactory-lb is running (i.e. _not_ the public agent ELB).

The default username and password is `admin` and `password` respectively.

For instructions on how to use Artifactory as a Docker Registry, see [this
guide](using-artifactory.md).
