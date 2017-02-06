# How to use NGINX on DC/OS

[NGINX](https://www.nginx.com) is a high-performance HTTP server, reverse proxy, and an IMAP/POP3 proxy server. NGINX is known for its high performance, stability, rich feature set, simple configuration, and low resource consumption. DC/OS allows you to quickly configure, install and manage NGINX.

- Estimated time for completion: 10 minutes
- Target audience: Anyone interested in running a HTTP (proxy) server
- Scope: Learn how to install NGINX on DC/OS and to serve a static website

## Prerequisites

- A running DC/OS 1.8 cluster with at least 1 node having at least 1 CPUs and 1 GB of RAM available.
- [DC/OS CLI](https://dcos.io/docs/1.8/usage/cli/install/) installed.

**Warning**: The current package will not work on RHEL 7.2 with Docker 1.11 due to a none DC/OS related issue.

## Install NGINX

Assuming you have a DC/OS cluster up and running, we install NGINX to serve up a static Web site, available via the GitHub repo [mesosphere/hello-nginx](https://github.com/mesosphere/hello-nginx).

Let's get started by creating a file called `options.json` with following contents:

```json
{
  "nginx": {
    "cpus": 1,
    "mem": 1024,
    "bridge": true,
    "contentUrl":"https://github.com/mesosphere/hello-nginx/archive/master.zip",
    "contentDir":"hello-nginx-master/"
  }
}
```

The above `options.json` file configures NGINX as follows:

- `cpus`: This parameter configures the number of CPU share to allocate to NGINX.
- `mem`: This parameter configures the amount of RAM to allocate to NGINX.
- `bridge`: This parameter configures whether the container should use `BRIDGE` mode networking or not. If this parameter is false, NGINX will be launched using `HOST` mode networking for docker. For more details, please refer to [Docker documentation](https://docs.docker.com/).
- `contentUrl`: This parameter is the URL to a file archive of a static website that we would like to serve using NGINX.
- `contentDir`: This parameter is the name of the directory that gets created when the file specified using `contentUrl` is downloaded and uncompressed.

Next, we are going to install nginx using this `options.json` file:

```bash
$ dcos package install nginx --options=options.json
Preparing to install nginx.
Continue installing? [yes/no] yes
Installing Marathon app for package [nginx] version [1.10.2]
Nginx has been installed.
```

To verify that our NGINX instance is up and running, we can use `dcos task` command:

```bash
$ dcos task
NAME   HOST        USER  STATE  ID
nginx  10.0.3.226  root    R    nginx.717adc72-a10e-11e6-a327-b293d3681090
```

Let's try to access the `hello-world` website our NGINX server is serving by opening the URL `http://<YOUR-DCOS-MASTER-HOSTNAME>/service/nginx`. You should see a webpage similar to this:

![Hello World NGINX on DC/OS](img/hello-nginx-dcos.png)

## Uninstall NGINX

To uninstall NGINX, run following command:

```bash
dcos package uninstall nginx
```

