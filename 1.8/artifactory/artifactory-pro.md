# Setting up Artifactory Pro on DC/OS

## Prerequisites

- DC/OS 1.8 or later with at least one public agent
- [DC/OS CLI installed](https://dcos.io/docs/1.8/usage/cli/install/) and configured to use your cluster
- Database (MySQL, Oracle, MS SQL Server or Postgres)
- Artifactory Enterprise license

## Setting up Artifactory Pro

1. Create a new file on your workstation, called `artifactory-pro-options.json`:

Be sure to:

- replace `service.license` with your own license string, separating multiple licenses with a comma (`,`) and no additional whitespace
- replace `service.database.user` and `service.database.password` with the correct values
- replace `DATABASE_NAME` within `service.database.connection-string` with the correct database name

```
{
  "service": {
    "name": "artifactory",
    "cpus": 2,
    "mem": 2048,
    "nodes": 1,
    "licenses": "$ARTIFACTORY_PRO_LICENSE",
    "host-volume": "/var/artifactory",
    "database": {
      "type": "mysql",
      "host": "mysql.marathon.mesos",
      "port": 3306,
      "url": "jdbc:mysql://mysql.marathon.mesos:3306/artdb?characterEncoding=UTF-8&elideSetAutoCommits=true",
      "user": "jfrogdcos",
      "password": "jfrogdcos"
    }
  },
  "pro": {
    "external-volumes": {
      "enabled": false,
      "provider": "dvdi",
      "driver": "rexray"
    }
  },
  "high-availability": {
    "enabled": false,
    "unique-nodes": true
  }
}

```

2. Run the following DC/OS CLI command to install Artifactory Pro:

```
dcos package install --options=artifactory-pro-option.json artifactory
```

3. Check that Artifactory is up and running successfully by checking the "Services" tab of DC/OS.

### Install Artifactory-lb

Once Artifactory is up and running, [follow this guide to set up Artifactory-lb](artifactory-lb.md).