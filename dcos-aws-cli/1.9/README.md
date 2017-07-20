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

The DC/OS AWS CLI currently supports only one command:
- Listing of external IP addresses
Retrieving the externally resolvable IP addresses of public Agents can be difficult, as DC/OS internally used the interal IP addresses. This command will list the external IP addresses for all public agents.

```bash
$ dcos dcos-aws-cli publicIPs
```


### Support and bug reports

This project is currently community supported, so feedback and  contributions are welcome.

- [DC/OS community Slack](chat.dcos.io)
- [Repository](https://github.com/dcos-labs/dcos-aws-cli)
