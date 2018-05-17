# How to use BeakerX on DC/OS

[BeakerX](http://beakerx.com) is a collection of kernels and extensions to the [Jupyter](http://http://jupyter.org) interactive computing environment. It provides JVM support, interactive plots, tables, forms, publishing, and more. `BeakerX` supports:

- Groovy, Scala, Clojure, Kotlin, Java, and SQL, including many magics and interactive widgets.
- Widgets for time-series plotting, tables, forms, and more. There are Python and JavaScript APIs in addition to the JVM languages.
- One-click publication with interactive plots and tables.
- Jupyter Lab

The `DC/OS BeakerX` package comes in a `base` version or a `GPU` version. 

#### Base version
The `base` version consists of the official [beakerx/beakerx](https://github.com/twosigma/beakerx/tree/master/docker) package with additionally installed packages tailored for Data Scientists needs:

- [H5PY](https://www.h5py.org/) 2.7.1
- [Keras](https://keras.io) 2.1.5
- [Numpy](http://www.numpy.org/) 1.14.2
- [Pandas](https://pandas.pydata.org/) 0.22.0
- [PySpark](https://spark.apache.org/docs/latest/api/python/index.html) 2.3.0
- [Scikit-Learn](http://scikit-learn.org/) 0.19.1
- [TensorFlow & TensorBoard](https://www.tensorflow.org/) 1.7.0
- [XLRD](https://pypi.org/project/xlrd/) 1.1.0

#### GPU version
The `GPU` version extends the `base` package with:

- [CUDA](https://developer.nvidia.com/cuda-toolkit/whatsnew) [9.0.176](https://gitlab.com/nvidia/cuda/blob/ubuntu16.04/9.0/base/Dockerfile)
- [CUDNN](https://developer.nvidia.com/cudnn) [7.1.3.16](https://gitlab.com/nvidia/cuda/blob/ubuntu16.04/9.0/runtime/cudnn7/Dockerfile )
- [TensorFlow-GPU](https://www.tensorflow.org/programmers_guide/using_gpu) 1.7.0

## Prerequisites

Required: 

- A running DC/OS 1.11 (or higher) cluster with at least 1 node (minimum 1 CPU, 4G of memory and 20GB of persistent disk storage in total)
- [DC/OS CLI](https://dcos.io/docs/1.11/cli/install/) installed.

Optional:

- [Marathon-LB](https://docs.mesosphere.com/services/marathon-lb/) ( Just needed for Advanced Installation with `external_access` enabled ) 

## Quick Start

To install `BeakerX` for the DC/OS, simply run `dcos package install beakerx` or install it via the Universe page in our DC/OS UI.

BeakerX should now be available at http://MASTERADDRESS/service/beakerx. 

Use the default password `dcos` to authenticate. 

You can run multiple installations of `BeakerX` by simply changing the `Service Name` during installation, the `dcos-beakerx` service provides full context to admin router of your individual installation.

See [advanced installation](#advanced-installation) for more in-depth instructions and configuration options.

## Install BeakerX without GPU Support

The default installation brings `BeakerX` up and running as described in [quick start](#quick-start). The advanced installation lets you customize your BeakerX installation even further. You can easily reach your `BeakerX` installation through the service weblink via the UI. 

### Deploy via UI

The DC/OS UI provides an intuitive way to deploy the `BeakerX` package on your DC/OS cluster.

1) Click on your `Catalog` tab and search for the `BeakerX` package.
2) Click `REVIEW & RUN` and then `EDIT` in the now opened modal.
3) Configure your package as needed in the [advanced installation](#advanced-installation), e.g. enabling persistence and external_access (more details provided in the package description).
4) Click `REVIEW & RUN` and then `RUN SERVICE` to deploy your `BeakerX` package as service.

### Deploy via CLI

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
Installing Marathon app for package [beakerx] version [0.15.2]
beakerx on DCOS installed successfully!
```


### Install BeakerX with GPU support

Before you can start, please make sure your cluster runs at least 1 GPU agent. See the instructions below that use Terraform to spin up a 1 master/1 GPU agent DC/OS cluster.

#### Installing a GPU Cluster on AWS via Terraform

As a prerequisite follow the [Getting Started Guide](https://github.com/dcos/terraform-dcos/blob/master/aws/README.md) of our Terraform repo, set your AWS Credentials profile and it your ssh-key to AWs. For an example Terraform deployment with GPU support on AWS follow these steps:

*Note: Create a new directory before the command below as terraform will write its files within the current directory.*
- Initialise your Terraform folder: `terraform init -from-module github.com/dcos/terraform-dcos//aws`
- Rename `desired_cluster_profile.tfvars.example` into `desired_cluster_profile.tfvar` and configure it like: 
``` 
dcos_cluster_name = "GPU BeakerX Testcluster"
dcos_version = "1.11.1"
num_of_masters = "1"
num_of_private_agents = "0"
num_of_public_agents = "0"
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
   Public Agent Public IPs = []
   ssh_user = core
```

You can now connect to your newly installed DC/OS cluster by copying the Master ELB Public IP into your browser. In our example this is `fabianbaie-tf7fcf-pub-mas-elb-1180697995.us-west-2.elb.amazonaws.com`

As a next step continue to deploy BeakerX with GPU Support.

#### Deploy BeakerX with GPU Support

### Deploy via UI

Watch the [video on how to deploy BeakerX on your cluster](https://cl.ly/1x1k3d1z383x).

The DC/OS UI provides an intuitive way to deploy the `BeakerX` package on your DC/OS cluster with GPU support. 


Steps as seen in the video are:

1) Click on your `Catalog` tab and search for the `BeakerX` package.
2) Click `REVIEW & RUN` and then `EDIT` in the now opened modal.
3) Configure your package as needed ( more details are in [advanced installation](#advanced-installation) ), in this case we enable GPU support and add 1 GPU.
4) Click `REVIEW & RUN` and then `RUN SERVICE` to deploy your `BeakerX` package as service.
5) The package has several gigabytes in size, typically the deployment takes 5 minutes on AWS.

### Deploy via CLI

The DC/OS CLI provides a convenient way to deploy `BeakerX` to your cluster. Create an `options.json` that looks like this:

```json
{
  "service": {
    "name": "beakerx-gpu",
    "cpus": 1,
    "gpu_support": {
      "enable": true,
      "gpus": 1
    },
    "mem": 2048
  },
  "storage": {
    "host_volume_size": 4000,
    "persistence": {
      "enable": false
    }
  },
  "networking": {
    "external_access": {
      "enable": false,
      "external_public_agent_ip": "",
      "external_access_port": 18888
    }
  }
}
```

*Note: See the `enable` field inside `gpu_support` is set to `true` and the `gpus` field is set to e.g. `1`*

Deploy the package via:

```bash
$ dcos package install beakerx --options=options.json --yes
By Deploying, you agree to the Terms and Conditions https://mesosphere.com/catalog-terms-conditions/#community-services
This DC/OS Service is currently in preview. There may be bugs, incomplete features, incorrect documentation, or other discrepancies.

Default password is set to 'dcos'

Advanced Installation options notes

storage / persistence: create local persistent volumes for internal storage files to survive across restarts or failures. 

storage / host_volume_size: define the size of your persistent volume, e.g. 4GB.

NOTE: If you didn't select persistence in the storage section, or provided a valid value for host_volume on installation,
YOUR DATA WILL NOT BE SAVED IN ANY WAY.

networking / port: This DC/OS service can be accessed from any other application through a NAMED VIP in the format service_name.marathon.l4lb.thisdcos.directory:port. Check status of the VIP in the Network tab of the DC/OS Dashboard (Enterprise DC/OS only).

networking / external_access: create an entry in Marathon-LB for accessing the service from outside of the cluster

networking / external_access_port: port to be used in Marathon-LB for accessing the service. 

networking / external_public_agent_ip: dns for Marathon-LB, typically set to your public agents public ip.

 Access your BeakerX Server.
Installing Marathon app for package [beakerx] version [0.15.2]
Service installed.
```
#### Test BeakerX with GPU Support and TensorFlow

After `BeakerX` was succesfully deployed authenticate with the default password described in quick start (pw: `dcos`) and create a new notebook in Python 3.

Make sure your GPU support works by simply running the following lines:

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

To access TensorBoard run start a Terminal in BeakerX and run the following command:

`tensorboard --logdir=<yourlogdir> --be_url=/service/beakerx/tensorboard`

Now you can access TensorBoard within your `BeakerX` instance simply by adding `/tensorboard/` to your browser url: `http://<clusterurl>/service/beakerx/tensorboard/`

*Note: If you installed your `BeakerX` service under a different name just adjust the name in the url.*


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

When enabling `external_access` you point via the `EXTERNAL_PUBLIC_AGENT_IP` field to your public agent DNS name. Please be sure to only use the DNS name without any leading `http://` or `https://`.

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

- Exec in your running container with the correct task id, in our example: `dcos task exec -it beakerx.083dbedb-d555-11e7-82be-4a630c070959 /bin/bash`
- In your container set the right permissions for `/home/beakerx/persistent_data` via:

```bash
$ chown -R beakerx:beakerx /home/beakerx/persistent_data
```

- Now when accessing your `BeakerX` service and uploading files to your `persistent_data` folder, e.g. notebooks, they are persistent stored.

## Use BeakerX 

By accessing `BeakerX` under the assigned host and port you are now able to authenticate and try the various [tutorials and examples](http://nbviewer.jupyter.org/github/twosigma/beakerx/blob/master/StartHere.ipynb).

## Further reading

### Uninstall BeakerX

Use the following commands to shut down and delete your bookkeeper service:

```bash
$ dcos package uninstall beakerx
Uninstalled package [beakerx] version [0.16.1]
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