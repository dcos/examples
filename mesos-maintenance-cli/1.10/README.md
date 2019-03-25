# How to use the DC/OS Maintenance CLI
The [Mesos Maintenance CLI](https://github.com/minyk/dcos-maintenance-cli) simplifies some maintenance operations for Mesos cluster of the DC/OS.

- Estimated time for completion: 2 minutes
- Target audience: Anyone running DC/OS cluster.
- Scope: Covers the basics in order to get you started with the DC/OS Mesos Maintenance CLI.

## Prerequisites

- A running DC/OS 1.10 cluster
- [DC/OS CLI](https://dcos.io/docs/1.10/usage/cli/install/) installed.

## Installation

The DC/OS CLI provides a convenient and currently only way to install this package:

```bash
$ dcos package install mesos-maintenance-cli
```

## Uninstallation

```bash
$ dcos package uninstall mesos-maintenance-cli
```

## Usage
Some subcommands using `CSV` formatted `host`/`ip` lists of target nodes. Example `list.csv` looks like:
```
# Host, IP
172.17.0.3,172.17.0.3
```

The DC/OS Mesos Maintenance CLI currently supports two subcommands:
- Managing maintenance schedule
 - View current schedule
```
$ dcos mesos-maintenance-cli schedule view
Window	Hostname   IP 		     Start				            Duration
0	     172.17.0.3       172.17.0.3     2019-03-26 09:00:00 +0900 KST	1h0m0s
```
 - Add new schedule
```
$ dcos mesos-maintenance-cli schedule add --start-at="2019-01-01" --duration="200s" --list="list.csv"
Maintenance schedule updated successfully.
```
   - `--start-at` can handle various formats due to `araddon/dateparse` library. See their examples: https://github.com/araddon/dateparse#extended-example
   - `--duration` uses unit character like these: `ns` for nanosecond, `us` for microsecond, `ms` for millisecond, `s` for second, `m` for minute, `h` for hour.
 - Remove existing schedule
```
$ dcos maintenance schedule remove --list="list.csv"
Maintenance schedule updated successfully.
```

- Start and Stop maintenance
 - Start the maintenance:
```
$ dcos maintenance machine down --list="list.csv"
Maintenance started for: 172.17.0.3
```
 - Stop the maintenance:
 ```
 $ dcos maintenance machine up --list="list.csv"
 Maintenance stopped for: 172.17.0.3
 ```


### Support and bug reports

Any feedback and contributions are welcome.

- [Repository](https://github.com/minyk/dcos-maintenance-cli)
