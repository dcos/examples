# How to use linkerd on DC/OS

[linkerd](https://linkerd.io) is a service mesh for DC/OS. It is installed on every agent, and acts as a transparent, load-balancing proxy, providing service discovery and resilient communication between services. DC/OS allows you to quickly configure, install, and manage linkerd. Once linkerd is set up, the [linkerd-viz](https://github.com/BuoyantIO/linkerd-viz) DC/OS package will provide immediate visibility and monitoring of services running in DC/OS.

- Estimated time for completion: 5 minutes
- Target audience: Anyone interested in inter-service communication and observability on DC/OS
- Scope: Learn how to install linkerd and linkerd-viz on DC/OS

**Table of Contents**:

- [Prerequisites](#prerequisites)
- [Install linkerd](#install-linkerd)
- [Install linkerd-viz](#install-linkerd-viz)
- [Further Reading](#further-reading)

## Prerequisites

- A running DC/OS 1.8 cluster with at least 1 [public agent](https://dcos.io/docs/1.8/overview/concepts/#public) node.
- [DC/OS CLI](https://dcos.io/docs/1.8/usage/cli/install/) installed.

## Install linkerd

The linkerd package in the DC/OS Universe repository installs linkerd on each agent node in the cluster. Applications can use their *node-local* linkerd instance to send traffic through the service mesh and take advantage service discovery, resilient communication, and top-line service metrics.

In order to use linkerd, applications must send traffic through it. Many HTTP applications (typically, those written in C, Go, Ruby, Python or PHP) can do this globally by setting an `http_proxy` environment variable to the address of their node-local linkerd instance. Other applications, including non-HTTP applications, will need to direct traffic to their local linkerd instances in other ways.

You can install linkerd on your DC/OS cluster with this command:

```bash
$ dcos package install --options=<(echo '{"linkerd":{"instances":<node count>}}') linkerd
```

Where `<node count>` is the number of agent nodes in your DC/OS cluster.

The linkerd service mesh will now be running on every agent node in your DC/OS cluster, ready to route requests by Marathon task name. To check that linkerd is working, [find the IP for a public node on your cluster](https://dcos.io/docs/1.8/administration/locate-public-agent/) and navigate to `http://<public node ip>:9990/`. You should see an admin page like this:

![admin](img/admin.png)

You can now send traffic to a service by connecting to linkerd and using the service's Marathon task name. For example, a request for `http://myapp/` on any linkerd instance will be proxied to, and load-balanced over, all instances of the *myapp* Marathon task. As instances of *myapp* are scaled up or down, or as instances become slow or disabled, linkerd will automatically adjust the destinations of these requests.

If *myapp* is an HTTP application, a quick way of verifying that the service mesh is up and running is to use `http_proxy` in conjunction with `curl`. For example:

```bash
$ http_proxy=<public agent ip>:4140 curl http://linkerd/admin/ping
```

## Install linkerd-viz

linkerd exports fine-grained metrics about the services that receive traffic on the mesh. We can use these to easily generate service dashboards by installing the *linkerd-viz* Universe package.

The linkerd-viz package is a bundle with Grafana and Prometheus, preconfigured to find linkerd instances and collect service metrics from them. This package will automatically display top-line service metrics for all services that are connected to by linkerd.

You can install the linkerd-viz package on your DC/OS cluster with this command:

```bash
$ dcos package install linkerd-viz
```

To check that linkerd-viz is working, navigate to `http://<public agent ip>:3000/`. You should see the linkerd-viz dashboard:

![linkerd-viz](img/linkerd-viz.png)

The dashboard includes three sections:

* TOP LINE. Cluster-wide success rate and request volume.
* SERVICE METRICS. One section for each application deployed. Includes success rate, request volume, and latency.
* PER-INSTANCE METRICS. Success rate, request volume, and latency for each node in your cluster.

As you send traffic through your system, you can the dashboard will update automatically to capture service performance, without configuration on your end.

## Further Reading

For a step-by-step example with a sample app, read the blog post: [DC/OS Blog: Service Discovery and Visibility with Ease on DC/OS](https://dcos.io/blog/2016/service-discovery-and-visibility-with-ease-on-dc-os/index.html)
