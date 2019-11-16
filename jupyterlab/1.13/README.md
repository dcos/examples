# How to use JupyterLab on DC/OS

[JupyterLab](https://github.com/jupyterlab/jupyterlab) is the next-generation user interface for [Project Jupyter](http://http://jupyter.org). It is an extensible environment for interactive and reproducible computing, based on the Jupyter Notebook and Architecture. The [Jupyter Notebook](https://github.com/jupyter/notebook) is an open-source web application that allows you to create and share documents that contain live code, equations, visualizations and narrative text. Uses include: data cleaning and transformation, numerical simulation, statistical modeling, data visualization, machine learning, and much more.

The initial release of the JupyterLab Notebook Service for Mesosphere DC/OS contains:

* [Apache Spark](https://spark.apache.org/docs/2.2.1) 2.2.1 -
Apache Spark™ is a unified analytics engine for large-scale data processing.
* [BeakerX](http://beakerx.com) 1.0.0 -
BeakerX is a collection of kernels and extensions to the Jupyter interactive computing environment. It provides JVM support, Spark cluster support, polyglot programming, interactive plots, tables, forms, publishing, and more.
* [Dask](https://dask.readthedocs.io) 0.18.2 -
Dask is a flexible parallel computing library for analytic computing.
* [Distributed](https://distributed.readthedocs.io) 1.22.0 -
Dask.distributed is a lightweight library for distributed computing in Python. It extends both the concurrent.futures and dask APIs to moderate sized clusters.
* [JupyterLab](https://jupyterlab.readthedocs.io) 0.33.4 -
JupyterLab is the next-generation web-based user interface for [Project Jupyter](https://jupyter.org).
* [PyTorch](https://pytorch.org) 0.4.0 -
Tensors and Dynamic neural networks in Python with strong GPU acceleration. PyTorch is a deep learning framework for fast, flexible experimentation.
* [Ray](https://ray.readthedocs.io) 0.5.0 -
Ray is a flexible, high-performance distributed execution framework.
  * Ray Tune: Hyperparameter Optimization Framework
  * Ray RLlib: Scalable Reinforcement Learning
* [TensorFlow](https://www.tensorflow.org) 1.9.0 -
TensorFlow™ is an open source software library for high performance numerical computation.
* [TensorFlowOnSpark](https://github.com/yahoo/TensorFlowOnSpark) 1.3.2 -
TensorFlowOnSpark brings TensorFlow programs onto Apache Spark clusters.
* [XGBoost](https://xgboost.ai) 0.72 -
Scalable, Portable and Distributed Gradient Boosting (GBDT, GBRT or GBM) Library, for Python, R, Java, Scala, C++ and more.

It also includes support for:
* OpenID Connect Authentication and Authorization based on email address or User Principal Name (UPN) (for Windows Integrated Authentication and AD FS 4.0 with Windows Server 2016)
* HDFS connectivity
* S3 connectivity
* GPUs with the `<image>:<tag>-gpu` Docker Image variant built from `Dockerfile-cuDNN`

Pre-built JupyterLab Docker Images for Mesosphere DC/OS: https://hub.docker.com/r/dcoslabs/dcos-jupyterlab/tags/

Related Docker Images:
 * Machine Learning Worker for Mesosphere DC/OS: https://hub.docker.com/r/dcoslabs/dcos-ml-worker/tags/
 * Apache Spark (with GPU support) for Mesosphere DC/OS: https://hub.docker.com/r/dcoslabs/dcos-spark/tags/

## Known Limitations

* Avoid using the host network (i.e., disabling the default CNI support) with OpenID Connect configurations as containers running on the same agent can bypass Authentication and Authorization checks.
* Multiple notebooks exposed via marathon_lb having the same prefix (e.g., jupyter-notebook and jupyter-notebook-user1) might conflict during marathon_lb routing. We recommend using Marathon folders to separate different notebooks into to their own unique namespace - e.g., `/jupyter-notebook, /dev/jupyter-notebook` and `/prod/jupyter-notebook`.


## Prerequisites

Required:

- A running DC/OS 1.11 (or higher) cluster with at least 1 node (minimum 1 CPU, 8G of memory and 20GB of persistent disk storage in total)
- [DC/OS CLI](https://docs.mesosphere.com/1.11/cli/install/) installed

Network Proxy:
- [Marathon-LB](https://docs.mesosphere.com/services/marathon-lb/) 
- [EdgeLB](https://docs.d2iq.com/mesosphere/dcos/services/edge-lb/1.5/) [![Generic badge](https://img.shields.io/badge/Enterprise-blueviolet.svg)](https://shields.io/)


## Quick Start

To install `JupyterLab` for the DC/OS, simply run `dcos package install jupyterlab --options=options.json` or install it via the Universe page in our DC/OS UI.

`JupyterLab` requires `Marathon-LB` and `1` public agent under which it can be reached. Make sure you specify the public agents vhost during installation time.

### Authenticating to your JupyterLab instance

You can run multiple installations of `JupyterLab` by simply changing the `Service Name` during installation. Each instance can have different authentication mechanisms configured.

#### Password Authentication

The default JupyterLab Notebook password is set to 'jupyter-<Marathon-App-Prefix>', e.g., with Marathon App ID '/foo/bar/app' it maps to the password: 'jupyter-foo-bar'.

- If you are in the main DC/OS space the password defaults to `jupyter`.

#### Custom Password

You can override the above under `Environment` in the `Jupyter_Password` field.

#### OIDC and Windows Integrated Authentication with AD FS 4.0 (Windows Server 2016)

The OpenID Connect flow will be triggered if both `OIDC_DISCOVERY_URI` and `OIDC_CLIENT_ID` are set, since they are the minimal options.

You can choose to enable OpenID Connect authentication. For (optional) authorization you can specify either an email adress: `OIDC_EMAIL` or User Principal Name (UPN) on Windows: `OIDC_UPN`

See [advanced installation](#advanced-installation) for more in-depth instructions and configuration options.

## Install JupyterLab without GPU Support

The default installation brings `JupyterLab` up and running as described in [quick start](#quick-start). The advanced installation lets you customize your `JupyterLab` installation even further. You can easily reach your `JupyterLab` installation through `Marathon-LB` via your vhost.

### Deploy via UI

The DC/OS UI provides an intuitive way to deploy the `JupyterLab` package on your DC/OS cluster.

1) Click on your `Catalog` tab and search for the `JupyterLab` package.
2) Click `REVIEW & RUN` and then `EDIT` in the now opened modal.
3) Configure your package as needed in the [advanced installation](#advanced-installation), e.g. enabling HDFS support (more details provided in the package description).
4) Click `REVIEW & RUN` and then `RUN SERVICE` to deploy your `JupyterLab` package as service.

### Deploy via CLI

The DC/OS CLI provides a convenient way to deploy applications on your DC/OS cluster. Create an `options.json` that looks like this:

Default [options.json](options.json)

Then install your `JupyterLab` service:

```bash
$ dcos package install jupyterlab --options=options.json --yes
By Deploying, you agree to the Terms and Conditions https://mesosphere.com/catalog-terms-conditions/#community-services
This DC/OS Service is currently in preview. There may be bugs, incomplete features, incorrect documentation, or other discrepancies.

Default password is set to 'jupyter-<Marathon-App-Prefix>'

Advanced Installation options notes

storage / persistence: create local persistent volumes for internal storage files to survive across restarts or failures.

storage / host_volume_size: define the size of your persistent volume, e.g. 4GB.

NOTE: If you didn't select persistence in the storage section, or provided a valid value for host_volume on installation,
YOUR DATA WILL NOT BE SAVED IN ANY WAY.

networking / port: This DC/OS service can be accessed from any other application through a NAMED VIP in the format service_name.marathon.l4lb.thisdcos.directory:port. Check status of the VIP in the Network tab of the DC/OS Dashboard (Enterprise DC/OS only).

networking / external_access: create an entry in Marathon-LB for accessing the service from outside of the cluster

networking / external_access_port: port to be used in Marathon-LB for accessing the service.

networking / external_public_agent_ip: dns for Marathon-LB, typically set to your public agents public ip.
Installing Marathon app for package [jupyterlab] version [1.1.0-0.33.4]
Service installed.
```


### Install JupyterLab with GPU support

Before you can start, please make sure your cluster runs at least 1 GPU agent. See the instructions below that use Terraform to spin up a 1 master/1 GPU agent DC/OS cluster.

#### Installing a GPU Cluster on AWS via Terraform

As a prerequisite follow the [Getting Started Guide](https://github.com/dcos/terraform-dcos/blob/master/aws/README.md) of our Terraform repo, set your AWS Credentials profile and copy your ssh-key to AWS. For an example Terraform deployment with GPU support on AWS follow these steps:

*Note: Create a new directory before the command below as terraform will write its files within the current directory.*
- Initialise your Terraform folder: `terraform init -from-module github.com/dcos/terraform-dcos//aws`
- Rename `desired_cluster_profile.tfvars.example` into `desired_cluster_profile.tfvar` and configure it like:
```
dcos_cluster_name = "GPU JupyterLab Testcluster"
dcos_version = "1.11.4"
num_of_masters = "1"
num_of_private_agents = "0"
num_of_public_agents = "1"
num_of_gpu_agents = "1"
#
aws_region = "us-west-2"
aws_bootstrap_instance_type = "m3.large"
aws_master_instance_type = "m4.2xlarge"
aws_agent_instance_type = "m4.2xlarge"
aws_profile = "123456-YourAWSProfile"
aws_public_agent_instance_type = "m4.2xlarge"
ssh_key_name = "yourSSHKey"
# Inbound Master Access
admin_cidr = "0.0.0.0/0"
```
- Activate GPU agent installation by renaming `dcos-gpu-agents.tf.disabled` into `dcos-gpu-agents.tf`
- Enable your GPU script via `terraform init`
- Apply your plan and run: `terraform apply -var-file desired_cluster_profile.tfvars`
- Approve Terraform to perform these actions by entering `yes` when prompted

If everything runs successful, the output looks like this:
```
Apply complete! Resources: 31 added, 0 changed, 0 destroyed.

   Outputs:

   Bootstrap Host Public IP = 34.215.7.137
   GPU Public IPs = [
       34.216.236.253
   ]
   Master ELB Public IP = fabianbaie-tf7fcf-pub-mas-elb-1180697995.us-west-2.elb.amazonaws.com
   Master Public IPs = [
       35.164.70.195
   ]
   Private Agent Public IPs = []
   Public Agent ELB Public IP = fabianbaie-tf7fcf-pub-agt-elb-2143488909.us-west-2.elb.amazonaws.com
   Public Agent Public IPs = [
       35.164.70.196
   }
   ssh_user = core
```

You can now connect to your newly installed DC/OS cluster by copying the Master ELB Public IP into your browser. In our example this is `fabianbaie-tf7fcf-pub-mas-elb-1180697995.us-west-2.elb.amazonaws.com`

As a next step continue to deploy Jupyter with GPU Support.

#### Deploy JupyterLab with GPU Support

You can enable `GPU Support` to your `JupyterLab` service if you want to run your Notebook with GPU acceleration.

### Deploy via UI

The DC/OS UI provides an intuitive way to deploy the `JupyterLab` package on your DC/OS cluster with GPU support.

Steps:

1) Click on your `Catalog` tab and search for the `JupyterLab` package.
2) Click `REVIEW & RUN` and then `EDIT` in the now opened modal.
3) Configure your package as needed (more details are in [advanced installation](#advanced-installation)), in this example we enable GPU support and add 1 GPU.
4) Click `REVIEW & RUN` and then `RUN SERVICE` to deploy your `JupyterLab` package as service.
5) The package has several gigabytes in size, typically the deployment takes 5 minutes on AWS.

### Deploy via CLI

The DC/OS CLI provides a convenient way to deploy `JupyterLab` to your cluster. Create an `options.json` that looks like this:

GPU enabled [options_advanced_gpu.json](options_advanced_gpu.json)

*Note: As you can see the `enable` field inside `gpu_support` is set to `true` and the `gpus` field is set to e.g. `1`*

Deploy the package via:

```bash
$ dcos package install jupyterlab --options=options_advanced_gpu.json --yes
By Deploying, you agree to the Terms and Conditions https://mesosphere.com/catalog-terms-conditions/#community-services
This DC/OS Service is currently in preview. There may be bugs, incomplete features, incorrect documentation, or other discrepancies.

Default password is set to 'jupyter-<Marathon-App-Prefix>'

Advanced Installation options notes

storage / persistence: create local persistent volumes for internal storage files to survive across restarts or failures.

storage / host_volume_size: define the size of your persistent volume, e.g. 4GB.

NOTE: If you didn't select persistence in the storage section, or provided a valid value for host_volume on installation,
YOUR DATA WILL NOT BE SAVED IN ANY WAY.

networking / port: This DC/OS service can be accessed from any other application through a NAMED VIP in the format service_name.marathon.l4lb.thisdcos.directory:port. Check status of the VIP in the Network tab of the DC/OS Dashboard (Enterprise DC/OS only).

networking / external_access: create an entry in Marathon-LB for accessing the service from outside of the cluster

networking / external_access_port: port to be used in Marathon-LB for accessing the service.

networking / external_public_agent_ip: dns for Marathon-LB, typically set to your public agents public ip.
Installing Marathon app for package [jupyterlab] version [1.1.0-0.33.4]
Service installed.
```

#### Test JupyterLab with GPU Support and TensorFlow

After `JupyterLab` was succesfully deployed authenticate with your password described in quick start and create a new notebook in Python 3.

*Note: Make sure `Marathon-LB` is installed.*

Check if you can access GPU acceleration by running the following lines in your new notebook:

```python
from tensorflow.python.client import device_lib

def get_available_devices():
    local_device_protos = device_lib.list_local_devices()
    return [x.name for x in local_device_protos]

print(get_available_devices())
```

The output should look like:

```apple js
['/device:CPU:0', '/device:GPU:0']
```

#### Access TensorBoard

You can access TensorBoard within your `JupyterLab` instance simply by adding `/tensorboard/` to your browser url: `https://<VHOST>/<Service Name>/tensorboard/`

*Note: If you installed your `JupyterLab` service under a different name space just adjust the name in the url.*

### Advanced Installation

#### Configuration

A typical advanced installation with e.g. HDFS support looks like this, where `external_public_agent_hostname` is the public hostname of e.g. your AWS ELB.

HDFS enabled [options_advanced_hdfs.json](options_advanced_hdfs.json)

*Note: For using HDFS you need to set your `jupyter_conf_urls` to the appropriate endpoint.*

You can create this `options_advanced_hdfs.json` manually or via the UI installation.

#### External Access

In order to access your `JupyterLab` service from outside the cluster you need to have the `Marathon-LB` service installed.

When enabling `external_access` you point via the `EXTERNAL_PUBLIC_AGENT_HOSTNAME` field to your public agent DNS name. Please be sure to only use the DNS name without any trailing `/` and leading `http://` or `https://`.

#### HDFS Support

Our `JupyterLab` Service fully supports `HDFS`. `HDFS` or `S3` is the recommended go-to when collaborating in multi-user environments. Simply install beforehand `HDFS` to your cluster, e.g. in the default settings. Also make sure you point `jupyter_conf_urls` under `Environment` to the appropriate URL, e.g. `http://api.hdfs.marathon.l4lb.thisdcos.directory/v1/endpoints` (Missing this step leads to a failing `JupyterLab` service).

#### Persistent Storage

When persistent storage is enabled you will find the `persistent_data` folder in your `JupyterLab` container under `/mnt/mesos/sandbox`.

Now when accessing your `JupyterLab` service and uploading files to your `persistent_data` folder they are persistent stored.

## Use JupyterLab and BeakerX

By accessing JupyterLab you are now able to authenticate and try the various [tutorials and examples](http://nbviewer.jupyter.org/github/twosigma/beakerx/blob/master/StartHere.ipynb) from and for `BeakerX`.

## Further reading

### Uninstall JupyterLab

If your service name was e.g. `/jupyterlab-notebook` use the following commands to shut down and delete your JupyterLab service:

```bash
$ dcos package uninstall jupyterlab --app-id=/jupyterlab-notebook
Uninstalled package [jupyterlab] version [1.1.1-0.33.4]
Service uninstalled. Note that any persisting data will be automatically removed from the agent where the service was deployed.
```

### Configuration options

There are a number of configuration options, which can be specified in the following
way:

```bash
$ dcos package install --config=<options> jupyterlab
```

where `options` is the path to a JSON file, e.g. `options.json`. For a list of possible
attribute values see

```bash
$ dcos package describe --config jupyterlab
```

### Changing your Python Version

*Following: [Installing the iPython Kernel](http://ipython.readthedocs.io/en/stable/install/kernel_install.html)*

In `File` click `new` and open a `Terminal`. In the terminal go ahead and create a new environment with your Python version of choice.

For Python `3.5`
```bash
$ conda create -n 3.5 python=3.5 ipykernel
$ source activate 3.5
$ python -m ipykernel install --user --name 3.5 --display-name "Python (3.5)"
$ source deactivate
```

When you reload your `Jupyter` page and click `Kernel` you can change now via `Change Kernel...` to your new installed Python `3.5` environment.

### Further Information

- [DC/OS JupyterLab Service](https://github.com/dcos-labs/dcos-jupyterlab-service)

### Release Notes and Versions

The initial release version was [1.2.0-0.33.7](https://github.com/dcos-labs/dcos-jupyterlab-service/releases/tag/1.2.0-0.33.7) and will be updated over time. A release history and the latest release can be found [here](https://github.com/dcos-labs/dcos-jupyterlab-service/releases).

| Version | Release Notes | Github |
|----------|----------|-------|
| `1.2.0-0.33.7` | [here](https://github.com/dcos-labs/dcos-jupyterlab-service/releases/tag/1.2.0-0.33.7) | [here](https://github.com/dcos-labs/dcos-jupyterlab-service/tree/1.2.0-0.33.7)  |

