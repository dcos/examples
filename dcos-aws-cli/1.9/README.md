# How to use the DC/OS AWS CLI
The [DC/OS AWS CLI](https://github.com/dcos-labs/dcos-aws-cli) simplifies some operations for cluster running on AWS.  

- Estimated time for completion: 2 minutes
- Target audience: Anyone running DC/OS cluster on AWS. Beginner level.
- Scope: Covers the basics in order to get you started with the DC/OS AWS CLI.

## Prerequisites

- A running DC/OS 1.9 cluster/
- [DC/OS CLI](https://dcos.io/docs/1.9/usage/cli/install/) installed.
- SSH key with access to your cluster configured (i.e., `dcos node ssh` should work)

## Installation

The DC/OS CLI provides a convenient and currently only way to install this package:

```bash
$ dcos package install dcos-aws-cli
```

## Usage

The DC/OS AWS CLI currently supports only two commands:
- Listing of external IP addresses
Retrieving the externally resolvable IP addresses of public Agents can be difficult, as DC/OS internally uses the internal IP addresses. This command will list the external IP addresses for all public agents.

```bash
$ dcos dcos-aws-cli publicIPs
35.158.189.26
```

- List all applications and their ports running on public agents
Checking all apps running on public agents and their ports can be a tedious task. This command lists all apps which have reserved port resources on a public Agent. Note that this does not--yet--include applications which are exposed via marathon-lb or applications which use unreserved ports.

```bash
$ dcos dcos-aws-cli exposedApps
AppName: nexus, PublicIP: 35.158.189.26, Ports: [9649-9649]
AppName: nginx, PublicIP: 35.158.189.26, Ports: [80]
```


### Support and bug reports

This project is currently community supported, so feedback and  contributions are welcome.

- [DC/OS community Slack](chat.dcos.io)
- [Repository](https://github.com/dcos-labs/dcos-aws-cli)
