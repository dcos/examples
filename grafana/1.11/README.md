# How to use Grafana on DC/OS

[Grafana](https://grafana.com/) allows you to query, visualize, alert on and understand your metrics no matter where they are stored. Create, explore, and share dashboards with your team and foster a data driven culture.

The DC/OS Grafana service enables you to connect to any of your metric backend services running in DC/OS using the VIP or Mesos DNS endpoint. This enables Grafana to seamlessly reconnect to the backend across service restarts without any additional configuration. It is fully configurable via grafana.ini and supports provisioning of datasources and dashboards including persistence through a Mesos volume.

- Estimated time for completion: 10 minutes
- Target audience: Anyone interested in application/platform performance metrics.
- Scope:
 - Install the DC/OS Grafana service.
 - Configure volume persistence.
 - Configure instance name.
 - Provision the datasource.

**Table of Contents**

- [Prerequisites](#prerequisites)
- [Install Grafana](#install-grafana)
 - [Configure Persistence](#configure-persistence)
 - [Provision Datasource](#provision-datasource)
- [Login to Grafana](#login-to-grafana)
- [Verify Datasource](#verify-datasource)
- [Create Dashboards](#create-dashboards)

## Prerequisites

- A running DC/OS 1.11 cluster
- A running DC/OS metric backend such as [Prometheus](https://docs.mesosphere.com/services/prometheus/)

## Install Grafana

The two options for installing Grafana are UI or DC/OS CLI. If you're just testing out the system and don't need to configure advanced deployment options, choose UI. If you have atypical deployment requirements or wish to automate the installation (such as an Ansible deployment) use the CLI.

### UI Install

In DC/OS UI, Click Catalog and search for 'grafana'. Click the Grafana 5.5.0-5.3.4 icon.

#### Configure Service
The default configuration will be adequate to get running immediately. However, it is recommended that you change the user appropriately and that the user has RW access to the configured volume in the grafana configuration.

#### Configure Grafana
Here you may configure the resource requirements along with the grafana.ini and provisioning files. The defaults should work fine out of the box. Make sure you understand the implications of any changes you make here.

It is recommended you change the instance name to the cluster name but it is not required.

##### Provision Datasources
You can provision the datasources YAML here according to [Grafana Provisioning](http://docs.grafana.org/administration/provisioning/). Note that the url configuration option should point to the VIP endpoint of your datasource running in DC/OS. This ensures seamless reconnection across datasource restarts.

##### Provision Dashboards
You can provision dashboards YAML here according to [Grafana Provisioning](http://docs.grafana.org/administration/provisioning/)

### CLI Install
The CLI install allows you to pass a custom deploy options json. This is useful for automated deployment workflows such as with Ansible (sample below). Note that the ini and provisioning YAML fields must be base64 encoded.

```bash
$ dcos package install grafana --yes --options=/path/to/deploy-options.json
```
deploy-options.json:
```
{
  "service": {
    "name": "grafana",
    "user": "{{ grafana_user }}",
    "service_account": "{{ grafana_service_account }}",
    "service_account_secret": "{{ grafana_service_account_secret }}",
    "log_level": "{{ grafana_service_log_level }}"
  },
  "grafana": {
    "cpus": {{ grafana_cpus }},
    "mem": {{ grafana_mem }},
    "volume": {
      "path": "{{ grafana_volume_path }}",
      "type": "{{ grafana_volume_type }}",
      "size": {{ grafana_volume_size }}
    },
    "ini": "{{ base64_encoded_ini }}",
    "provisioning": {
      "datasources": "{{ base64_encoded_yml }}",
      "dashboards": "{{ base64_encoded_yml }}"
    }
  }
}
```

## Login to Grafana
Navigate to the Grafana service Endpoints tab. Copy the Address field and paste it into a new tab.
Enter the user/pass admin/admin. You will be prompted to change the password.

## Verify Datasource
Hover on the gear icon in the left nav and click Datasources. If you provisioned datasources properly at install time, they should show up here. Note that provisioned datasources may not be modified in the UI. You must edit the Grafana service configuration and restart it.

Your datasource may come with some default dashboards which will be visible on the Dashboards tab of the datasource. Click this, import dashboard(s) and check that they are functioning.

## Create Dashboards
Create dashboards according to your datasource's specific query language from [grafana datasources documentation](http://docs.grafana.org/features/datasources/). Start with a [graph](http://docs.grafana.org/features/panels/graph/) and go from there!
