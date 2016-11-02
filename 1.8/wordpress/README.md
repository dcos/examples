---
post_title: Deploying WordPress on DC/OS
menu_order: 1
enterprise: 'yes'
---





In this tutorial we will deploy a simple containerized [WordPress][1] site using the packages available in the DC/OS Universe.

**Prerequisites:**

*   A DC/OS cluster with at least 1 [private agent][4] and 1 [public agent][4]. You can [deploy a cluster to the public cloud][5] or follow the [enterprise installation instructions][6].
*   The fully qualified domain name of your DC/OS [public agent][7].
* The DC/OS CLI installed on your local machine.


# Quick Start

You will need to install three things to deploy WordPress on DC/OS:

1. [Marathon-LB][2] to make WordPress externally accessible.

2. A MySQL database for WordPress to store its metadata.

3. WordPress itself!

Each of these three are already available in the Universe, the package registry for DC/OS.

## Install Marathon-LB

[Marathon-LB][2] is an HA-proxy-based load balancer for DC/OS. It provides an easy, highly available way to route requests to the applications running on your cluster.

Simply install Marathon-LB from the DC/OS CLI:

`dcos package install marathon-lb`

Alternatively, you can install Marathon-LB from the **Universe** tab of the DC/OS web interface.

For advanced Marathon-LB configuration, including how to provide custom configuration and how to enable HTTPS, see the [Marathon-LB Getting Started guide][3].

## Setting up MySQL

Set up MySQL via the DC/OS user interface or the command line.

If you are installing from the CLI, create a file called `config.json` Set the following properties for easy installation:

```json
{
  "mysql": {
    "root_password": "wordpress",
    "database": {
      "name": "wordpress",
      "username": "wordpress",
      "password": "wordpress"
    }
  }
}
```

Then, install MySQL:

`dcos package install mysql --options=config.json`

Alternatively, from the DC/OS web interface, click the **Universe** tab and find MySQL. Click **Install Package**, then **Advanced Installation**. Fill in the `root_password` and `database` fields with the information in the code snippet above.

## Setting up WordPress

To make WordPress accessible to the world, we need to use the fully qualified domain name of your DC/OS public agent.

To install from the CLI, first create a `config.json` as below and replace the `virtual-host` property with your own:

```json
{
  "networking": {
    "virtual-host": "dcos.public.agent"
  }
}
```

Now use these options to install WordPress:

`dcos package install wordpress --options=config.json`

Alternatively, you can install WordPress from the DC/OS Universe. Just make sure to specify the `virtual-host` using "Advanced Installation".

## View WordPress

Once you've installed the necessary components, navigate to the domain name of your DC/OS public agent in your browser. You should now see the WordPress welcome wizard!

![WordPress welcome wizard](../img/wordpress-welcome.png)

# Production Considerations

By default, the WordPress package uses the `/tmp` directory on the node it runs on. If you plan to use this package for a production website, you will want to customize this to a well known directory (for example, `/var/wordpress`) that you can backup easily. You will also want to specify the DC/OS host to pin the instance to, so if the package is ever upgraded or otherwise restarts, it is able to deploy to the same node.

An example `config.json` might look something like the following:

```json
{
  "service": {
    "name": "wordpress-prod",
  },
  "networking": {
    "virtual-host": "dcos.public.agent",
  },
  "storage": {
    "host-volume": "/var/wordpress",
    "pinned-hostname": "10.0.1.1"
  }
}
```


 [1]: https://wordpress.com/
 [2]: https://github.com/mesosphere/marathon-lb
 [3]: /1.8/usage/service-discovery/marathon-lb/
 [4]: /1.8/administration/locate-public-agent/
 [5]: /1.8/administration/installing/cloud/
 [6]: /1.8/administration/installing/custom/
 [7]: /1.8/overview/concepts/#public
 