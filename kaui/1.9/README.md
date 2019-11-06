# How to use Kaui on DC/OS

Kaui is the administrative UI for [Kill Bill](https://killbill.io/), the open-source subscription billing and payments platform.

**Table of Contents**:

- [Prerequisites](#prerequisites)
- [Configure MySQL](#configure-mysql)
- [Install Kaui](#install-kaui)
- [Next steps](#next-steps)

## Prerequisites

- A running DC/OS 1.9 cluster with at least 1 node with 1 CPU and 2 GB of RAM available.
- [DC/OS CLI](https://dcos.io/docs/1.9/usage/cli/install/) installed.
- MySQL and Kill Bill installed.

## Configure MySQL

Setup the DDL (replace `a1.dcos` with the hostname returned by `dcos task mysql`):

```bash
echo "create database kaui" | mysql -h a1.dcos -u root -proot
curl -s https://raw.githubusercontent.com/killbill/killbill-admin-ui/master/db/ddl.sql | mysql -h a1.dcos -u root -proot kaui
echo "insert into kaui_allowed_users (kb_username, description, created_at, updated_at) values ('admin', 'super admin', NOW(), NOW());" | mysql -h a1.dcos -u root -proot kaui
echo "create user kaui identified by 'kaui' ; grant all privileges on kaui.* to 'kaui'@'%' ; flush privileges" | mysql -h a1.dcos -u root -proot
```

## Install Kaui

Create a file called `config.json` and set the following properties:

```json
{
  "database": {
    "host": "a1.dcos:3306",
    "name": "kaui",
    "user": "kaui",
    "password": "kaui"
  },
  "killbill": {
    "host": "http://marathon-lb-internal.marathon.mesos:10080"
  }
}
```

Then, install Kaui:

```bash
dcos package install kaui --yes --options=config.json
```

You can follow the installation process via:

```bash
dcos task log kaui --follow
```

Verify the installation was successful by visiting http://m1.dcos/service/kaui/ (replace `m1.dcos` with the hostname of your Marathon instance). Note: you need to be logged-in in Marathon.

Additionally, verify the integration with Marathon-lb by going to http://a1.dcos:9090/haproxy?stats (replace `a1.dcos` with the hostname returned by `dcos task marathon-lb-internal`). You should see entries for `kaui_10090`. Running `curl http://a1.dcos:10090` a few times should update the HAProxy stats. Kaui is now available in the cluster behind `marathon-lb-internal.marathon.mesos:10090`.

## Next steps

Documentation and tutorials can be found at http://docs.killbill.io/.