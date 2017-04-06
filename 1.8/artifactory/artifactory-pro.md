# Setting up Artifactory Pro on DC/OS

## Prerequisites

- DC/OS 1.8 or later with at least one public agent
- [DC/OS CLI installed](https://dcos.io/docs/1.8/usage/cli/install/) and configured to use your cluster
- Database (MySQL, Oracle, MS SQL Server or Postgres)
- Artifactory Enterprise license

## Setting up Artifactory Pro

1. Create a new file on your workstation, called `artifactory-pro-options.json`:

Be sure to:

- replace `service.licenses` with your own license string
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
      "url": "jdbc:mysql://mysql.marathon.mesos:3306/artdb?characterEncoding=UTF-8&elideSetAutoCommits=true",
      "user": "jfrogdcos",
      "password": "jfrogdcos"
    }
  }
}
```

2. Run the following DC/OS CLI command to install Artifactory Pro:

```
dcos package install --options=artifactory-pro-options.json artifactory
```

3. Check that Artifactory is up and running successfully by checking the "Services" tab of DC/OS.

### Install Artifactory-lb

Once Artifactory is up and running, [follow this guide to set up Artifactory-lb](artifactory-lb.md).