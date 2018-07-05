# Setting up MySQL on DC/OS for Artifactory

## Prerequisites

- DC/OS 1.11 or later with at least one public agent
- [DC/OS CLI installed](https://dcos.io/docs/1.11/usage/cli/install/) and
  configured to use your cluster

## Setting up MySQL:

1. Create a new file called `mysql-options.json` with following content:

```
{
  "service": {
    "name": "mysql"
  },
  "mysql": {
    "cpus": 0.5,
    "mem": 512
  },
  "database": {
    "name": "artdb",
    "username": "jfrogdcos",
    "password": "jfrogdcos",
    "root_password": "root"
  },
  "storage": {
    "host_volume": "/tmp",
    "persistence": {
      "enable": false,
      "volume_size": 256,
      "external": {
        "enable": false,
        "volume_name": "mysql",
        "provider": "dvdi",
        "driver": "rexray"
      }
    }
  },
  "networking": {
    "port": 3306,
    "host_mode": true,
    "external_access": {
      "enable": false,
      "external_access_port": 13306
    }
  }
}
```

2. Run this command to install MySQL:

```
dcos package install --options=mysql-options.json mysql
```

3. Make sure MySQL is running and is healthy by looking under the Services tab
   in the DC/OS UI.

WARNING: mysql-options.json mentioned in this page is a sample setting sufficient to trial the Artifactory package.
We do not currently recommend using this sample for a production deployment of Artifactory. 
DB choice, CPU, memory and volume size needs to be picked and adjusted based on the expected load for 
the production Artifactory.