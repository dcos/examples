# How to use BeakerX on DC/OS

[BeakerX](http://beakerx.com) is a collection of kernels and extensions to the [Jupyter](http://http://jupyter.org) interactive computing environment. It provides JVM support, interactive plots, tables, forms, publishing, and more. `BeakerX` supports:

- Groovy, Scala, Clojure, Kotlin, Java, and SQL, including many magics and interactive widgets.
- Widgets for time-series plotting, tables, forms, and more. There are Python and JavaScript APIs in addition to the JVM languages.
- One-click publication with interactive plots and tables.
- Jupyter Lab

## Prerequisites

Required: 

- A running DC/OS 1.10 cluster with at least 1 node, at least having 1 CPU, 2G of memory and 6GB of persistent disk storage in total.
- [DC/OS CLI](https://dcos.io/docs/1.10/cli/install/) installed.

Optional:

- [Marathon-LB](https://dcos.io/docs/1.10/networking/marathon-lb/) ( Just needed for Advanced Installation with `external_access` enabled ) 

## Quick Start

To install BeakerX for the DC/OS, simply run `dcos package install beakerx` or install via the Universe page in the DC/OS UI.

BeakerX should now be available at http://MASTERADDRESS/service/beakerx. 

Use the default password `dcos` to authenticate. 

You can run multiple installations of BeakerX by simply changing the `Service Name` during installation, the `dcos-beakerx` service provides full context to admin router of your individual installation.

See [advanced installation](#advanced-installation) for more in-depth instructions and configuration options.

## Install BeakerX 

The default installation brings BeakerX up and running as descripted in the [quick start](#quick-start) with an automatically created link from the DC/OS UI to the framework web UI. The advanced installation lets you customize your BeakerX installation even further. 

### Install via UI

The DC/OS UI provides an intuitive way to deploy the `BeakerX` package on your DC/OS cluster.

1) Click on your `Catalog` tab and search for the `BeakerX` package.
2) Click `REVIEW & RUN` and then `EDIT` in the now opened modal.
3) Configure your package as needed in the [advanced installation](#advanced-installation), e.g. enabling persistence and external_access (more details provided in the package description).
4) Click `REVIEW & RUN` and then `RUN SERVICE` to deploy your `BeakerX` package as service.

### Install via CLI

The DC/OS CLI provides a convenient way to deploy applications on your DC/OS cluster:

```bash
$ dcos package install beakerx --yes
This DC/OS Service is currently in preview. There may be bugs, incomplete features, incorrect documentation, or other discrepancies.

Find the server token to authenticate in your service's stdout

Advanced Installation options notes

storage / persistence: create local persistent volumes for internal storage files to survive across restarts or failures.

storage / host_volume_size: define the size of your persistent volume, e.g. 4GB.

NOTE: If you didn't select persistence in the storage section, or provided a valid value for host_volume on installation,
YOUR DATA WILL NOT BE SAVED IN ANY WAY.

networking / port: This DC/OS service can be accessed from any other application through a NAMED VIP in the format service_name.marathon.l4lb.thisdcos.directory:port. Check status of the VIP in the Network tab of the DC/OS Dashboard (Enterprise DC/OS only).

networking / external_access: create an entry in Marathon-LB for accessing the service from outside of the cluster

networking / external_access_port: port to be used in Marathon-LB for accessing the service. 

networking / external_public_agent_ip: dns for Marathon-LB, typically set to your public agents public ip.

Access your BeakerX Server.",
Installing Marathon app for package [beakerx] version [0.8.1]
beakerx on DCOS installed successfully!
```

### Advanced Installation


#### Configuration

A typical advanced installation with `external_access` and `persistent_storage` enabled looks like this, where `external_public_agent_ip` is the public ip of e.g. your aws elb.

options.json
```json
{
  "service": {
    "name": "beakerx",
    "cpus": 1,
    "mem": 2048
  },
  "storage": {
    "host_volume_size": 4000,
    "persistence": {
      "enable": true
    }
  },
  "networking": {
    "port_api": 8888,
    "external_access": {
      "enable": true,
      "external_public_agent_ip": "tf-publicslaveload-eqjlmfefk3x1-1807985788.us-west-2.elb.amazonaws.com",
      "external_access_port": 18888
    }
  }
}
```

You can create this `options.json` manually or via the UI installation.

#### External Access

In order to access your `BeakerX` service from outside the cluster you need to have the `Marathon-LB` service installed. 

By enabling `external_access` you would need to add also your public agent's public ip to the `EXTERNAL_PUBLIC_AGENT_IP` field at installation time as seen in the configuration example above.

#### Persistent Storage

If you enabled persistent storage you need to set the right permissions in your `BeakerX` container to access the `persistent_data` folder. This can be achieved by using the `dcos task exec -it <beakerx.taskid> /bin/bash` command. 

- You need to find the task-id your `BeakerX` service is running under:

```bash
$ dcos task
   NAME         HOST       USER  STATE  ID                                                MESOS ID                                 
   beakerx      10.0.1.91  root    R    beakerx.083dbedb-d555-11e7-82be-4a630c070959      ebed2c7d-4f38-41b8-889c-3efb9d8fb5ea-S4  
   marathon-lb  10.0.4.85  root    R    marathon-lb.48ef761e-d542-11e7-82be-4a630c070959  ebed2c7d-4f38-41b8-889c-3efb9d8fb5ea-S0  
   universe     10.0.3.14  root    R    universe.cc89525a-d554-11e7-82be-4a630c070959     ebed2c7d-4f38-41b8-889c-3efb9d8fb5ea-S6  
```

- Exec in your running container: `dcos task exec -it beakerx.083dbedb-d555-11e7-82be-4a630c070959 /bin/bash`
- In your container set the right permissions for `/home/beakerx/persistent_data` via:

```bash
$ chown -R beakerx:beakerx /home/beakerx/persistent_data
```

- Now when accessing your `beakerx` service and uploading files to your `persistent_data` folder, e.g. notebooks, they are persistent stored.

## Use BeakerX 

The server will generate a password for you, and print it on the console. If you are trying for the first time to access your service, you need to authenticate via this random token. 

You can find this token when accessing your servers `stderr` log under the `Service` tab in the UI.

Typical output:
```$xslt
[I 22:31:36.765 NotebookApp] Writing notebook server cookie secret to /home/beakerx/.local/share/jupyter/runtime/notebook_cookie_secret
[W 22:31:36.781 NotebookApp] WARNING: The notebook server is listening on all IP addresses and not using encryption. This is not recommended.
[I 22:31:36.786 NotebookApp] [beakerx] enabled
[I 22:31:36.789 NotebookApp] Serving notebooks from local directory: /home/beakerx
[I 22:31:36.789 NotebookApp] 0 active kernels
[I 22:31:36.789 NotebookApp] The Jupyter Notebook is running at:
[I 22:31:36.789 NotebookApp] http://[all ip addresses on your system]:8888/?token=5978d01ed2fdde4370f044986ecc758a952f5726386b4322
[I 22:31:36.789 NotebookApp] Use Control-C to stop this server and shut down all kernels (twice to skip confirmation).
[C 22:31:36.789 NotebookApp] 
    
    Copy/paste this URL into your browser when you connect for the first time,
    to login with a token:
        http://localhost:8888/?token=5978d01ed2fdde4370f044986ecc758a952f5726386b4322
```

By accessing `BeakerX` under the assigned host and port you are now able to authenticate and try the various [tutorials and examples](http://nbviewer.jupyter.org/github/twosigma/beakerx/blob/master/StartHere.ipynb).

*Note: Make sure you remember that token in case you have to re-authenticate or get logged out*

## Further reading

### Uninstall BeakerX

Use the following commands to shut down and delete your bookkeeper service:

```bash
$ dcos package uninstall beakerx
Uninstalled package [beakerx] version [0.8.1]
Service uninstalled. Note that any persisting data will be automatically removed from the agent where the service was deployed.
```

### Configuration options

There are a number of configuration options, which can be specified in the following
way:

```bash
$ dcos package install --config=<options> beakerx
```

where `options` is the path to a JSON file, e.g. `options.json`. For a list of possible
attribute values see

```bash
$ dcos package describe --config beakerx
```

### Changing your Python Version

*Following: [Installing the iPython Kernel](http://ipython.readthedocs.io/en/stable/install/kernel_install.html)*

In `BeakerX` click `new` and open a `Terminal`. In the terminal go ahead and create a new environment with your Python version of choice.

For Python `3.5`
```bash
$ conda create -n 3.5 python=3.5 ipykernel
$ source activate 3.5
$ python -m ipykernel install --user --name 3.5 --display-name "Python (3.5)"
$ source deactivate
```

When you reload your `BeakerX` page and click `new` you can choose now `Python (3.5)` as your kernel running your installed Python `3.5` environment.


### Further Information

- [Website BeakerX](http://beakerx.com)
- [Github BeakerX](https://github.com/twosigma/beakerx)
