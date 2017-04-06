# Setting up Artifactory Enterprise on DC/OS

[Artifactory Enterprise](https://www.jfrog.com/artifactory/versions/#High-Availability) is a highly available installation of Artifactory. It does this by using a load balancer to balance requests across multiple Artifactory instances.

![Artifactory Enterprise Architecture](img/HA_Diagram.png)

## Prerequisites

- DC/OS 1.8 or later with at least one public agent
- [DC/OS CLI installed](https://dcos.io/docs/1.8/usage/cli/install/) and configured to use your cluster
- Database (MySQL, Oracle, MS SQL Server or Postgres)
- Artifactory Enterprise license
- NFS directory mounted to each node

## Setting up Artifactory Enterprise

### Set up storage on each node (required for high availability)

All nodes need to be able to read and write to the same file share. We recommend using NFS (or an equivalent like [Amazon's EFS](https://aws.amazon.com/efs/)).

For example, using the default location of `/var/artifactory`, mount an example file share on each DC/OS private agent using the following command:

```
sudo mount artifactoryha.mount.com:/artifactory /var/artifactory/
```

You must ensure this mount is writeable.

### Setting up Artifactory Enterprise

1. Create a new file called `artifactory-enterprise-options.json` with the following content.

Be sure to:

- replace `service.licenses` with your own license string (only one node's license is required here, the rest can be configured in the Artifactory UI)
- replace `service.database.user` and `service.database.password` with the correct credentials if you have customised these
- replace `artdb` within `service.database.url` with the correct database name if you have used a different one

```
{
  "service": {
    "name": "artifactory",
    "licenses": "replaceme",
    "host-volume": "/var/artifactory",
    "database": {
      "type": "mysql",
      "host": "mysql.marathon.mesos",
      "port": 3306,
      "url": "jdbc:mysql://mysql.marathon.mesos:3306/DATABASE_NAME?characterEncoding=UTF-8&elideSetAutoCommits=true",
      "user": "jfrogdcos",
      "password": "jfrogdcos"
    }
  },
  "enterprise": {
    "enabled": true
  }
}
```


2. Run the following DC/OS CLI command to install Artifactory Enterprise:

```
dcos package install --options=artifactory-enterprise-options.json artifactory
```

3. Check that Artifactory is up and running successfully by checking the "Services" tab of DC/OS.

## Install Artifactory-lb

Once Artifactory is up and running, [follow this guide to set up Artifactory-lb](artifactory-lb.md).

## Scaling Artifactory Enterprise

To make Artifactory Enterprise highly available, simply add licenses and scale the application up!

1. Add more licenses for secondary nodes in Artifactory UI:

![Add More Licenses](img/add_licenses.png)

2. Run the following DC/OS CLI command to scale Artifactory Enterprise to 2 instances:

```
dcos marathon app update artifactory instances=2
```

