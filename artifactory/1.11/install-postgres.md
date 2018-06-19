# Setting up Postgres on DC/OS for Artifactory

## Prerequisites

- DC/OS 1.11 or later with at least one public agent
- [DC/OS CLI installed](https://dcos.io/docs/1.10/usage/cli/install/) and
  configured to use your cluster

## Setting up Postgres:

1. Create a new file called `postgresql-options.json` with following content:

```
{
  "service": {
    "name": "postgresql"
  },
  "postgresql": {
    "cpus": 0.5,
    "mem": 512
  },
  "database": {
    "username": "jfrogdcos",
    "password": "jfrogdcos",
    "dbname": "artifactory"
  },
  "storage": {
    "host_volume": "/tmp",
    "pgdata": "pgdata",
    "persistence": {
      "enable": false,
      "volume_size": 512,
      "external": {
        "enable": false,
        "volume_name": "postgresql",
        "provider": "dvdi",
        "driver": "rexray"
      }
    }
  },
  "networking": {
    "port": 5432,
    "host_mode": true,
    "external_access": {
      "enable": false,
      "external_access_port": 15432
    }
  }
}
```

2. Run this command to install Postgres:

```
dcos package install --options=postgresql-options.json postgresql
```

3. Make sure Postgres is running and is healthy by looking under the Services tab
   in the DC/OS UI.

This should be sufficient to trial the Artifactory package but we do not
currently recommend using this for a production deployment of Artifactory.
