# How to use Clair on DC/OS

[Clair](https://github.com/coreos/clair) is the a open source Docker image vulnerabilities scanner.

- Estimated time for completion: 15 minutes
- Target audience: Anyone interested in using Clair for scanning containers for vulnerabilities
- Scope: Learn how to install Clair, and use it for scanning containers

## Prerequisites

- A running DC/OS >= 1.8 cluster with at least 1 node having at least 0.5 CPUs and 1 GB of RAM available.
- [DC/OS CLI](https://dcos.io/docs/1.8/usage/cli/install/) installed.
- A running Postgres instance with a separate database for the vulnerability data, and the appropriate credentials.
- If you want to expose the Clair service outside of the DC/OS cluster, make sure you have a running instance of marathon-lb.

## Install Clair

### Via Marathon application definition

Please replace all the values in `<...>` with the real values. If you don't want to expose the Clair service externally, please omit the `HAPROXY_*` labels.

```javascript
{
  "id": "clair",
  "cpus": 0.5,
  "mem": 1024.0,
  "instances": 1,
  "container": {
    "type": "DOCKER",
    "docker": {
      "image": "tobilg/clair-dcos:v1.2.6",
      "network": "HOST"
    }
  },
  "env": {
    "POSTGRES_USER": "<username>",
    "POSTGRES_PASSWORD": "<password>",
    "POSTGRES_DATABASE": "<database>",
    "POSTGRES_HOST": "<databaseHost>",
    "POSTGRES_PORT": "<databasePort>",
    "POSTGRES_TIMEOUT_SECONDS": "30"
  },
  "labels": {
    "HAPROXY_GROUP": "external",
    "HAPROXY_0_VHOST": "<publicSlaveELBHostname>",
    "HAPROXY_0_PORT": "6060"
  },
  "portDefinitions": [
    {
      "port": 0,
      "protocol": "tcp",
      "name": "http",
      "labels": {
        "VIP_0": "clair:6060"
      }
    },
    {
      "port": 0,
      "protocol": "tcp",
      "name": "health-check"
    }
  ],
  "requirePorts": false,
  "healthChecks": [
    {
      "protocol": "HTTP",
      "portIndex": 1,
      "path": "/health",
      "gracePeriodSeconds": 5,
      "intervalSeconds": 20,
      "maxConsecutiveFailures": 3
    }
  ]
}
```

Your service will then be availably internally via the VIP `clair.marathon.l4lb.thisdcos.directory:6060`, or externally on `<externalPublicSlaveHostname>:6060`.

### Via Universe package

You can prepare a `clair.json` file with the installation options. Please replace all the values in `<...>` with the real values.

```javascript
{
  "service": {
    "name": "clair",
    "cpus": 1,
    "mem": 2048
  },
  "basic": {
    "update_interval": 1,
    "api_timeout": 900,
    "cache_size": 16384
  },
  "networking": {
    "enable_external": true,
    "virtual_host": "<publicSlaveELBHostname>",
    "port": 6060
  },
  "postgres": {
    "user": "<username>",
    "password": "<password>",
    "database": "<database>",
    "host": "<databaseHost>",
    "port": <databasePort>,
    "timeout_seconds": 30
  }
}
```

If you don't want to expose the Clair service outside of the cluster, please use the following `clair.json`:

```javascript
{
  "service": {
    "name": "clair",
    "cpus": 1,
    "mem": 2048
  },
  "basic": {
    "update_interval": 1,
    "api_timeout": 900,
    "cache_size": 16384
  },
  "networking": {
    "enable_external": false
  },
  "postgres": {
    "user": "<username>",
    "password": "<password>",
    "database": "<database>",
    "host": "<databaseHost>",
    "port": <databasePort>,
    "timeout_seconds": 30
  }
}
```

Run the installation with the dcos CLI like this:

```bash
$ dcos package install clair --options=clair.json
```

## Usage

**It can take between 30 to 60 minutes to initially load the vulnerability database**, so please keep that in mind when trying to query Clair right after the service started.

Once the data is loaded, you'll see the following message in the Clair service's stdout:

```bash
updater: update finished
```

After that, the vulnerabilities database is ready to use, and Clair will actually deliver useful results.

### With klar

[klar](https://github.com/optiopay/klar) is a CLI tool which can make use of Clair. It works well for CI/CD integration use cases.

```bash
$ CLAIR_ADDR=<publicSlaveELBHostname> CLAIR_THRESHOLD=0 DOCKER_USER=<registryUser> DOCKER_PASSWORD=<registryPassword> klar redis
```

This will generate an output like this:

```bash
Analysing 24 layers
Found 57 vulnerabilities
<snip>
CVE-2017-5336: [High]
Stack-based buffer overflow in the cdk_pk_get_keyid function in lib/opencdk/pubkey.c in GnuTLS before 3.3.26 and 3.5.x before 3.5.8 allows remote attackers to have unspecified impact via a crafted OpenPGP certificate.
https://security-tracker.debian.org/tracker/CVE-2017-5336
-----------------------------------------
CVE-2017-5337: [High]
Multiple heap-based buffer overflows in the read_attribute function in GnuTLS before 3.3.26 and 3.5.x before 3.5.8 allow remote attackers to have unspecified impact via a crafted OpenPGP certificate.
https://security-tracker.debian.org/tracker/CVE-2017-5337
-----------------------------------------
CVE-2017-5334: [High]
Double free vulnerability in the gnutls_x509_ext_import_proxy function in GnuTLS before 3.3.26 and 3.5.x before 3.5.8 allows remote attackers to have unspecified impact via crafted policy language information in an X.509 certificate with a Proxy Certificate Information extension.
https://security-tracker.debian.org/tracker/CVE-2017-5334
-----------------------------------------
Unknown: 6
Negligible: 28
Low: 6
Medium: 10
High: 7
```

### With clairctl

[clairctl](https://github.com/jgsqware/clairctl) is another CLI tool which can make use of Clair. 

Make sure you have a `$HOME/.clairctl.yml` file defined similar to this, where `<publicSlaveELBHostname>` is the actual address of the public agent (ELB), or the VIP if you just run it in the DC/OS cluster locally:

```yaml
clair:
  port: 6060
  uri: <publicSlaveELBHostname>
  report:
    path: ./reports
    format: html
```


```bash
$ clairctl ananlyze redis --config $HOME/.clairctl.yml
```
### Via the Clair API

Clair can also be used via its [API](https://github.com/coreos/clair/blob/master/Documentation/api_v1.md) directly.
