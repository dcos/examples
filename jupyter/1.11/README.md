# How to use Jupyter on DC/OS

[JupyterLab](https://github.com/jupyterlab/jupyterlab) is the next-generation user interface for [Project Jupyter](http://http://jupyter.org). It is an extensible environment for interactive and reproducible computing, based on the Jupyter Notebook and Architecture. The [Jupyter Notebook](https://github.com/jupyter/notebook) is an open-source web application that allows you to create and share documents that contain live code, equations, visualizations and narrative text. Uses include: data cleaning and transformation, numerical simulation, statistical modeling, data visualization, machine learning, and much more.

The initial release of the JupyterLab Notebook Service for Mesosphere DC/OS contains:

* [Apache Spark](https://spark.apache.org/docs/2.2.1) 2.2.1 - 
Apache Spark™ is a unified analytics engine for large-scale data processing.
* [BeakerX](http://beakerx.com) 1.0.0 -
BeakerX is a collection of kernels and extensions to the Jupyter interactive computing environment. It provides JVM support, Spark cluster support, polyglot programming, interactive plots, tables, forms, publishing, and more.
* [Dask](https://dask.readthedocs.io) 0.18.1 -
Dask is a flexible parallel computing library for analytic computing.
* [Distributed](https://distributed.readthedocs.io) 1.22.0 -
Dask.distributed is a lightweight library for distributed computing in Python. It extends both the concurrent.futures and dask APIs to moderate sized clusters.
* [JupyterLab](https://jupyterlab.readthedocs.io) 0.32.1 -
JupyterLab is the next-generation web-based user interface for [Project Jupyter](https://jupyter.org).
* [PyTorch](https://pytorch.org) 0.4.0 -
Tensors and Dynamic neural networks in Python with strong GPU acceleration. PyTorch is a deep learning framework for fast, flexible experimentation.
* [Ray](https://ray.readthedocs.io) 0.5.0 -
Ray is a flexible, high-performance distributed execution framework.
  * Ray Tune: Hyperparameter Optimization Framework
  * Ray RLlib: Scalable Reinforcement Learning
* [TensorFlow](https://www.tensorflow.org) 1.8.0 -
TensorFlow™ is an open source software library for high performance numerical computation.
* [TensorFlowOnSpark](https://github.com/yahoo/TensorFlowOnSpark) 1.3.0 -
TensorFlowOnSpark brings TensorFlow programs onto Apache Spark clusters.
* [XGBoost](https://xgboost.ai) 0.72 -
Scalable, Portable and Distributed Gradient Boosting (GBDT, GBRT or GBM) Library, for Python, R, Java, Scala, C++ and more.
 
It also includes support for:
* OpenID Connect Authentication and Authorization based on email address or User Principal Name (UPN) (for Windows Integrated Authentication and AD FS 4.0 with Windows Server 2016)
* HDFS connectivity
* S3 connectivity
* GPUs with the `<image>:<tag>-gpu` Docker Image variant built from `Dockerfile-cuDNN`
 
Pre-built JupyterLab Docker Images for Mesosphere DC/OS: https://hub.docker.com/r/dcoslabs/dcos-jupyter/tags/
 
Related Docker Images:
 * Machine Learning Worker for Mesosphere DC/OS: https://hub.docker.com/r/dcoslabs/dcos-ml-worker/tags/
 * Apache Spark (with GPU support) for Mesosphere DC/OS: https://hub.docker.com/r/dcoslabs/dcos-spark/tags/

## Prerequisites

Required: 

- A running DC/OS 1.11 (or higher) cluster with at least 1 node (minimum 1 CPU, 4G of memory and 20GB of persistent disk storage in total)
- [DC/OS CLI](https://dcos.io/docs/1.11/cli/install/) installed
- [Marathon-LB](https://docs.mesosphere.com/services/marathon-lb/)

## Quick Start

To install `Jupyter` for the DC/OS, simply run `dcos package install jupyter` or install it via the Universe page in our DC/OS UI.

`Jupyter` requires `Marathon-LB` and `1` public agent under which it can be reached. Make sure you specify the public agents vhost during installation time.

### Authenticating to your Jupyter instance

You can run multiple installations of `Jupyter` by simply changing the `Service Name` during installation. Each instance can have different authentication mechanisms configured.

#### Password Authentication

The default Jupyter Notebook Server password is set to 'jupyter-<Marathon-App-Prefix>', e.g., with Marathon App ID '/foo/bar/app' it maps to the password: 'jupyter-foo-bar'. 

- If you are in the main DC/OS space the password will be `jupyter`.

#### Custom Password

You can override the above by setting under `Environment` a `Jupyter_Password`.

#### OIDC and Windows Integrated Authentication with AD FS 4.0 (Windows Server 2016)

The OpenID Connect flow will be triggered if both `OIDC_DISCOVERY_URI` and `OIDC_CLIENT_ID` are set, since they are the minimal options.

You can choose to enable OpenID Connect authentication. For (optional) authorization you can specify either an email adress: `OIDC_EMAIL` or User Principal Name (UPN) on Windows: `OIDC_UPN`

See [advanced installation](#advanced-installation) for more in-depth instructions and configuration options.

## Install Jupyter without GPU Support

The default installation brings `Jupyter` up and running as described in [quick start](#quick-start). The advanced installation lets you customize your `Jupyter` installation even further. You can easily reach your `Jupyter` installation through `Marathon-LB` via your vhost. 

### Deploy via UI

The DC/OS UI provides an intuitive way to deploy the `Jupyter` package on your DC/OS cluster.

1) Click on your `Catalog` tab and search for the `Jupyter` package.
2) Click `REVIEW & RUN` and then `EDIT` in the now opened modal.
3) Configure your package as needed in the [advanced installation](#advanced-installation), e.g. enabling persistence and external_access (more details provided in the package description).
4) Click `REVIEW & RUN` and then `RUN SERVICE` to deploy your `Jupyter` package as service.

### Deploy via CLI

The DC/OS CLI provides a convenient way to deploy applications on your DC/OS cluster. Create an `options.json` that looks like this:

```json
{
  "service": {
    "name": "/jupyter-notebook",
    "cmd": "/usr/local/bin/start.sh ${CONDA_DIR}/bin/jupyter lab --notebook-dir=\"/mnt/mesos/sandbox\"",
    "cpus": 1,
    "force_pull": false,
    "gpu_support": {
      "enabled": false,
      "gpus": 0
    },
    "mem": 8192,
    "user": "nobody"
  },
  "oidc": {
    "enable_oidc": false,
    "oidc_discover_uri": "https://keycloak.example.com/auth/realms/Notebook/.well-known/openid-configuration",
    "oidc_redirect_uri": "/oidc-redirect-callback",
    "oidc_client_id": "Notebook",
    "oidc_client_secret": "b874f6e9-8f3f-41a6-a206-53e928d24fb1",
    "oidc_tls_verify": "no",
    "enable_windows": false,
    "oidc_use_email": false,
    "oidc_email": "user@example.com",
    "oidc_upn": "user007",
    "oidc_logout_path": "/logmeout",
    "oidc_post_logout_redirect_uri": "https://<VHOST>/<optional PATH_PREFIX>/<Service Name>",
    "oidc_use_spartan_resolver": true
  },
  "spark": {
    "enable_spark_monitor": true,
    "spark_master_url": "mesos://zk://zk-1.zk:2181,zk-2.zk:2181,zk-3.zk:2181,zk-4.zk:2181,zk-5.zk:2181/mesos",
    "spark_driver_cores": 2,
    "spark_driver_memory": "4g",
    "spark_driver_java_options": "\"-XX:+UseG1GC -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/mnt/mesos/sandbox\"",
    "spark_conf_spark_scheduler": "spark.scheduler.minRegisteredResourcesRatio=1.0",
    "spark_conf_cores_max": "spark.cores.max=5",
    "spark_conf_executor_cores": "spark.executor.cores=1",
    "spark_conf_executor_memory": "spark.executor.memory=4g",
    "spark_conf_executor_java_options": "spark.executor.extraJavaOptions=\"-XX:+UseG1GC -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/mnt/mesos/sandbox\"",
    "spark_conf_eventlog_enabled": "spark.eventLog.enabled=true",
    "spark_conf_eventlog_dir": "spark.eventLog.dir=s3a://your-dcos-aws/spark/history",
    "spark_conf_hadoop_fs_s3a_aws_credentials_provider": "spark.hadoop.fs.s3a.aws.credentials.provider=com.amazonaws.auth.InstanceProfileCredentialsProvider",
    "spark_conf_mesos_executor_docker_image": "spark.mesos.executor.docker.image=vishnumohan/spark-dcos:tfos",
    "spark_conf_mesos_executor_home": "spark.mesos.executor.home=/opt/spark",
    "spark_conf_mesos_containerizer": "spark.mesos.containerizer=mesos",
    "spark_conf_mesos_principle": "spark.mesos.principal=dev_jupyter",
    "spark_conf_mesos_role": "spark.mesos.role=dev-jupyter",
    "spark_conf_mesos_driver_labels": "spark.mesos.driver.labels=DCOS_SPACE:/dev/jupyter",
    "spark_conf_mesos_task_labels": "spark.mesos.task.labels=DCOS_SPACE:/dev/jupyter",
    "spark_conf_mesos_conf_base64": "spark.mesos.driverEnv.SPARK_MESOS_KRB5_CONF_BASE64=W2xpYmRlZmF1bHRzXQoJZGVmYXVsdF9yZWFsbSA9IEFUSEVOQS5NSVQuRURVCgpbcmVhbG1zXQojIHVzZSAia2RjID0gLi4uIiBpZiByZWFsbSBhZG1pbnMgaGF2ZW4ndCBwdXQgU1JWIHJlY29yZHMgaW50byBETlMKCUFUSEVOQS5NSVQuRURVID0gewoJCWFkbWluX3NlcnZlciA9IGtlcmJlcm9zLm1pdC5lZHUKCX0KCUFORFJFVy5DTVUuRURVID0gewoJCWFkbWluX3NlcnZlciA9IGtkYy0wMS5hbmRyZXcuY211LmVkdQoJfQoKW2RvbWFpbl9yZWFsbV0KCW1pdC5lZHUgPSBBVEhFTkEuTUlULkVEVQoJY3NhaWwubWl0LmVkdSA9IENTQUlMLk1JVC5FRFUKCS51Y3NjLmVkdSA9IENBVFMuVUNTQy5FRFUKCltsb2dnaW5nXQojCWtkYyA9IENPTlNPTEUK",
    "spark_conf_executor_conf_base64": "spark.executorEnv.SPARK_MESOS_KRB5_CONF_BASE64=W2xpYmRlZmF1bHRzXQoJZGVmYXVsdF9yZWFsbSA9IEFUSEVOQS5NSVQuRURVCgpbcmVhbG1zXQojIHVzZSAia2RjID0gLi4uIiBpZiByZWFsbSBhZG1pbnMgaGF2ZW4ndCBwdXQgU1JWIHJlY29yZHMgaW50byBETlMKCUFUSEVOQS5NSVQuRURVID0gewoJCWFkbWluX3NlcnZlciA9IGtlcmJlcm9zLm1pdC5lZHUKCX0KCUFORFJFVy5DTVUuRURVID0gewoJCWFkbWluX3NlcnZlciA9IGtkYy0wMS5hbmRyZXcuY211LmVkdQoJfQoKW2RvbWFpbl9yZWFsbV0KCW1pdC5lZHUgPSBBVEhFTkEuTUlULkVEVQoJY3NhaWwubWl0LmVkdSA9IENTQUlMLk1JVC5FRFUKCS51Y3NjLmVkdSA9IENBVFMuVUNTQy5FRFUKCltsb2dnaW5nXQojCWtkYyA9IENPTlNPTEUK",
    "spark_conf_executor_krb5_config": "spark.executorEnv.KRB5_CONFIG=/mnt/mesos/sandbox/krb5.conf",
    "spark_conf_executor_java_home": "spark.executorEnv.JAVA_HOME=/opt/jdk",
    "spark_conf_executor_hadoop_hdfs_home": "spark.executorEnv.HADOOP_HDFS_HOME=/opt/hadoop",
    "spark_conf_executor_hadoop_opts": "spark.executorEnv.HADOOP_OPTS=\"-Djava.library.path=/opt/hadoop/lib/native -Djava.security.krb5.conf=/mnt/mesos/sandbox/krb5.conf\"",
    "spark_conf_mesos_executor_docker_forcepullimage": "spark.mesos.executor.docker.forcePullImage=true",
    "spark_conf_mesos_uri": "spark.mesos.uris=http://api.devhdfs.marathon.l4lb.thisdcos.directory/v1/endpoints/hdfs-site.xml,http://api.devhdfs.marathon.l4lb.thisdcos.directory/v1/endpoints/core-site.xml",
    "spark_mesos_conf_krb5_config": "W2xpYmRlZmF1bHRzXQoJZGVmYXVsdF9yZWFsbSA9IEFUSEVOQS5NSVQuRURVCgpbcmVhbG1zXQojIHVzZSAia2RjID0gLi4uIiBpZiByZWFsbSBhZG1pbnMgaGF2ZW4ndCBwdXQgU1JWIHJlY29yZHMgaW50byBETlMKCUFUSEVOQS5NSVQuRURVID0gewoJCWFkbWluX3NlcnZlciA9IGtlcmJlcm9zLm1pdC5lZHUKCX0KCUFORFJFVy5DTVUuRURVID0gewoJCWFkbWluX3NlcnZlciA9IGtkYy0wMS5hbmRyZXcuY211LmVkdQoJfQoKW2RvbWFpbl9yZWFsbV0KCW1pdC5lZHUgPSBBVEhFTkEuTUlULkVEVQoJY3NhaWwubWl0LmVkdSA9IENTQUlMLk1JVC5FRFUKCS51Y3NjLmVkdSA9IENBVFMuVUNTQy5FRFUKCltsb2dnaW5nXQojCWtkYyA9IENPTlNPTEUK",
    "spark_user": "nobody"
  },
  "storage": {
    "hdfs_support": false,
    "hdfs_core_url": "http://api.devhdfs.marathon.l4lb.thisdcos.directory/v1/endpoints/core-site.xml",
    "hdfs_site_url": "http://api.devhdfs.marathon.l4lb.thisdcos.directory/v1/endpoints/hdfs-site.xml",
    "persistence": {
      "host_volume_size": 4000,
      "enable": false
    }
  },
  "networking": {
    "cni_support": {
      "enabled": false
    },
    "external_access": {
      "enabled": true,
      "external_public_agent_ip": "https://<VHOST>/<optional PATH_PREFIX>/<Service Name>"
    }
  },
  "environment": {
    "secrets": false,
    "service_credential": "dev/jupyter/serviceCredential",
    "aws_region": "us-east-1",
    "conda_envs_path": "/mnt/mesos/sandbox/conda/envs:/opt/conda/envs",
    "conda_pkgs_dir": "/mnt/mesos/sandbox/conda/pkgs:/opt/conda/pkgs",
    "dcos_dir": "/mnt/mesos/sandbox/.dcos",
    "hadoop_conf_dir": "/mnt/mesos/sandbox",
    "home": "/mnt/mesos/sandbox",
    "java_opts": "\"-XX:+UseG1GC -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/mnt/mesos/sandbox\"",
    "jupyter_config_dir": "/mnt/mesos/sandbox/.jupyter",
    "jupyter_password": "",
    "jupyter_runtime_dir": "/mnt/mesos/sandbox/.local/share/jupyter/runtime",
    "nginx_log_level": "warn",
    "s3_endpoint": "s3.us-east-1.amazonaws.com",
    "s3_https": 1,
    "s3_ssl": 1,
    "start_dask_distributed": true,
    "start_ray_head_node": true,
    "user": "nobody",
    "tensorboard_logdir": "/mnt/mesos/sandbox",
    "term": "xterm-256color"
  }
}
```

Then install your `Jupyter` service:

```bash
$ dcos package install jupyter --options=options.json --yes
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
Installing Marathon app for package [jupyter] version [1.11.3-0.32.1]
Service installed.
```


### Install Jupyter with GPU support

Before you can start, please make sure your cluster runs at least 1 GPU agent. See the instructions below that use Terraform to spin up a 1 master/1 GPU agent DC/OS cluster.

#### Installing a GPU Cluster on AWS via Terraform

As a prerequisite follow the [Getting Started Guide](https://github.com/dcos/terraform-dcos/blob/master/aws/README.md) of our Terraform repo, set your AWS Credentials profile and it your ssh-key to AWs. For an example Terraform deployment with GPU support on AWS follow these steps:

*Note: Create a new directory before the command below as terraform will write its files within the current directory.*
- Initialise your Terraform folder: `terraform init -from-module github.com/dcos/terraform-dcos//aws`
- Rename `desired_cluster_profile.tfvars.example` into `desired_cluster_profile.tfvar` and configure it like: 
``` 
dcos_cluster_name = "GPU Jupyter Testcluster"
dcos_version = "1.11.3"
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

#### Deploy Jupyter with GPU Support

### Deploy via UI

Watch the [video on how to deploy Jupyter on your DC/OS cluster](https://cl.ly/1x1k3d1z383x).

The DC/OS UI provides an intuitive way to deploy the `Jupyter` package on your DC/OS cluster with GPU support. 


Steps as seen in the video are:

1) Click on your `Catalog` tab and search for the `Jupyter` package.
2) Click `REVIEW & RUN` and then `EDIT` in the now opened modal.
3) Configure your package as needed ( more details are in [advanced installation](#advanced-installation) ), in this case we enable GPU support and add 1 GPU.
4) Click `REVIEW & RUN` and then `RUN SERVICE` to deploy your `Jupyter` package as service.
5) The package has several gigabytes in size, typically the deployment takes 5 minutes on AWS.

### Deploy via CLI

The DC/OS CLI provides a convenient way to deploy `Jupyter` to your cluster. Create an `options.json` that looks like this:

```json
{
  "service": {
    "name": "/jupyter-notebook",
    "cmd": "/usr/local/bin/start.sh ${CONDA_DIR}/bin/jupyter lab --notebook-dir=\"/mnt/mesos/sandbox\"",
    "cpus": 1,
    "force_pull": false,
    "gpu_support": {
      "enabled": true,
      "gpus": 1
    },
    "mem": 8192,
    "user": "nobody"
  },
  "oidc": {
    "enable_oidc": false,
    "oidc_discover_uri": "https://keycloak.example.com/auth/realms/Notebook/.well-known/openid-configuration",
    "oidc_redirect_uri": "/oidc-redirect-callback",
    "oidc_client_id": "Notebook",
    "oidc_client_secret": "b874f6e9-8f3f-41a6-a206-53e928d24fb1",
    "oidc_tls_verify": "no",
    "enable_windows": false,
    "oidc_use_email": false,
    "oidc_email": "user@example.com",
    "oidc_upn": "user007",
    "oidc_logout_path": "/logmeout",
    "oidc_post_logout_redirect_uri": "https://<VHOST>/<optional PATH_PREFIX>/<Service Name>",
    "oidc_use_spartan_resolver": true
  },
  "spark": {
    "enable_spark_monitor": true,
    "spark_master_url": "mesos://zk://zk-1.zk:2181,zk-2.zk:2181,zk-3.zk:2181,zk-4.zk:2181,zk-5.zk:2181/mesos",
    "spark_driver_cores": 2,
    "spark_driver_memory": "4g",
    "spark_driver_java_options": "\"-XX:+UseG1GC -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/mnt/mesos/sandbox\"",
    "spark_conf_spark_scheduler": "spark.scheduler.minRegisteredResourcesRatio=1.0",
    "spark_conf_cores_max": "spark.cores.max=5",
    "spark_conf_executor_cores": "spark.executor.cores=1",
    "spark_conf_executor_memory": "spark.executor.memory=4g",
    "spark_conf_executor_java_options": "spark.executor.extraJavaOptions=\"-XX:+UseG1GC -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/mnt/mesos/sandbox\"",
    "spark_conf_eventlog_enabled": "spark.eventLog.enabled=true",
    "spark_conf_eventlog_dir": "spark.eventLog.dir=s3a://your-dcos-aws/spark/history",
    "spark_conf_hadoop_fs_s3a_aws_credentials_provider": "spark.hadoop.fs.s3a.aws.credentials.provider=com.amazonaws.auth.InstanceProfileCredentialsProvider",
    "spark_conf_mesos_executor_docker_image": "spark.mesos.executor.docker.image=vishnumohan/spark-dcos:tfos",
    "spark_conf_mesos_executor_home": "spark.mesos.executor.home=/opt/spark",
    "spark_conf_mesos_containerizer": "spark.mesos.containerizer=mesos",
    "spark_conf_mesos_principle": "spark.mesos.principal=dev_jupyter",
    "spark_conf_mesos_role": "spark.mesos.role=dev-jupyter",
    "spark_conf_mesos_driver_labels": "spark.mesos.driver.labels=DCOS_SPACE:/dev/jupyter",
    "spark_conf_mesos_task_labels": "spark.mesos.task.labels=DCOS_SPACE:/dev/jupyter",
    "spark_conf_mesos_conf_base64": "spark.mesos.driverEnv.SPARK_MESOS_KRB5_CONF_BASE64=W2xpYmRlZmF1bHRzXQoJZGVmYXVsdF9yZWFsbSA9IEFUSEVOQS5NSVQuRURVCgpbcmVhbG1zXQojIHVzZSAia2RjID0gLi4uIiBpZiByZWFsbSBhZG1pbnMgaGF2ZW4ndCBwdXQgU1JWIHJlY29yZHMgaW50byBETlMKCUFUSEVOQS5NSVQuRURVID0gewoJCWFkbWluX3NlcnZlciA9IGtlcmJlcm9zLm1pdC5lZHUKCX0KCUFORFJFVy5DTVUuRURVID0gewoJCWFkbWluX3NlcnZlciA9IGtkYy0wMS5hbmRyZXcuY211LmVkdQoJfQoKW2RvbWFpbl9yZWFsbV0KCW1pdC5lZHUgPSBBVEhFTkEuTUlULkVEVQoJY3NhaWwubWl0LmVkdSA9IENTQUlMLk1JVC5FRFUKCS51Y3NjLmVkdSA9IENBVFMuVUNTQy5FRFUKCltsb2dnaW5nXQojCWtkYyA9IENPTlNPTEUK",
    "spark_conf_executor_conf_base64": "spark.executorEnv.SPARK_MESOS_KRB5_CONF_BASE64=W2xpYmRlZmF1bHRzXQoJZGVmYXVsdF9yZWFsbSA9IEFUSEVOQS5NSVQuRURVCgpbcmVhbG1zXQojIHVzZSAia2RjID0gLi4uIiBpZiByZWFsbSBhZG1pbnMgaGF2ZW4ndCBwdXQgU1JWIHJlY29yZHMgaW50byBETlMKCUFUSEVOQS5NSVQuRURVID0gewoJCWFkbWluX3NlcnZlciA9IGtlcmJlcm9zLm1pdC5lZHUKCX0KCUFORFJFVy5DTVUuRURVID0gewoJCWFkbWluX3NlcnZlciA9IGtkYy0wMS5hbmRyZXcuY211LmVkdQoJfQoKW2RvbWFpbl9yZWFsbV0KCW1pdC5lZHUgPSBBVEhFTkEuTUlULkVEVQoJY3NhaWwubWl0LmVkdSA9IENTQUlMLk1JVC5FRFUKCS51Y3NjLmVkdSA9IENBVFMuVUNTQy5FRFUKCltsb2dnaW5nXQojCWtkYyA9IENPTlNPTEUK",
    "spark_conf_executor_krb5_config": "spark.executorEnv.KRB5_CONFIG=/mnt/mesos/sandbox/krb5.conf",
    "spark_conf_executor_java_home": "spark.executorEnv.JAVA_HOME=/opt/jdk",
    "spark_conf_executor_hadoop_hdfs_home": "spark.executorEnv.HADOOP_HDFS_HOME=/opt/hadoop",
    "spark_conf_executor_hadoop_opts": "spark.executorEnv.HADOOP_OPTS=\"-Djava.library.path=/opt/hadoop/lib/native -Djava.security.krb5.conf=/mnt/mesos/sandbox/krb5.conf\"",
    "spark_conf_mesos_executor_docker_forcepullimage": "spark.mesos.executor.docker.forcePullImage=true",
    "spark_conf_mesos_uri": "spark.mesos.uris=http://api.devhdfs.marathon.l4lb.thisdcos.directory/v1/endpoints/hdfs-site.xml,http://api.devhdfs.marathon.l4lb.thisdcos.directory/v1/endpoints/core-site.xml",
    "spark_mesos_conf_krb5_config": "W2xpYmRlZmF1bHRzXQoJZGVmYXVsdF9yZWFsbSA9IEFUSEVOQS5NSVQuRURVCgpbcmVhbG1zXQojIHVzZSAia2RjID0gLi4uIiBpZiByZWFsbSBhZG1pbnMgaGF2ZW4ndCBwdXQgU1JWIHJlY29yZHMgaW50byBETlMKCUFUSEVOQS5NSVQuRURVID0gewoJCWFkbWluX3NlcnZlciA9IGtlcmJlcm9zLm1pdC5lZHUKCX0KCUFORFJFVy5DTVUuRURVID0gewoJCWFkbWluX3NlcnZlciA9IGtkYy0wMS5hbmRyZXcuY211LmVkdQoJfQoKW2RvbWFpbl9yZWFsbV0KCW1pdC5lZHUgPSBBVEhFTkEuTUlULkVEVQoJY3NhaWwubWl0LmVkdSA9IENTQUlMLk1JVC5FRFUKCS51Y3NjLmVkdSA9IENBVFMuVUNTQy5FRFUKCltsb2dnaW5nXQojCWtkYyA9IENPTlNPTEUK",
    "spark_user": "nobody"
  },
  "storage": {
    "hdfs_support": false,
    "hdfs_core_url": "http://api.devhdfs.marathon.l4lb.thisdcos.directory/v1/endpoints/core-site.xml",
    "hdfs_site_url": "http://api.devhdfs.marathon.l4lb.thisdcos.directory/v1/endpoints/hdfs-site.xml",
    "persistence": {
      "host_volume_size": 4000,
      "enable": false
    }
  },
  "networking": {
    "cni_support": {
      "enabled": false
    },
    "external_access": {
      "enabled": true,
      "external_public_agent_ip": "jupyter-publicslav-a9w05wgw3px4-959689447.us-west-2.elb.amazonaws.com"
    }
  },
  "environment": {
    "secrets": false,
    "service_credential": "dev/jupyter/serviceCredential",
    "aws_region": "us-east-1",
    "conda_envs_path": "/mnt/mesos/sandbox/conda/envs:/opt/conda/envs",
    "conda_pkgs_dir": "/mnt/mesos/sandbox/conda/pkgs:/opt/conda/pkgs",
    "dcos_dir": "/mnt/mesos/sandbox/.dcos",
    "hadoop_conf_dir": "/mnt/mesos/sandbox",
    "home": "/mnt/mesos/sandbox",
    "java_opts": "\"-XX:+UseG1GC -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/mnt/mesos/sandbox\"",
    "jupyter_config_dir": "/mnt/mesos/sandbox/.jupyter",
    "jupyter_password": "",
    "jupyter_runtime_dir": "/mnt/mesos/sandbox/.local/share/jupyter/runtime",
    "nginx_log_level": "warn",
    "s3_endpoint": "s3.us-east-1.amazonaws.com",
    "s3_https": 1,
    "s3_ssl": 1,
    "start_dask_distributed": true,
    "start_ray_head_node": true,
    "user": "nobody",
    "tensorboard_logdir": "/mnt/mesos/sandbox",
    "term": "xterm-256color"
  }
}
```

*Note: See the `enable` field inside `gpu_support` is set to `true` and the `gpus` field is set to e.g. `1`*

Deploy the package via:

```bash
$ dcos package install jupyter --options=options.json --yes
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
Installing Marathon app for package [jupyter] version [1.11.3-0.32.1]
Service installed.
```

#### Test Jupyter with GPU Support and TensorFlow

After `Jupyter` was succesfully deployed authenticate with your password described in quick start and create a new notebook in Python 3.

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

You can access TensorBoard within your `Jupyter` instance simply by adding `/tensorboard/` to your browser url: `https://<VHOST>/<optional PATH_PREFIX>/<Service Name>/tensorboard/`

*Note: If you installed your `Jupyter` service under a different name just adjust the name in the url.*


### Advanced Installation

#### Configuration

A typical advanced installation with `external_access` and `persistent_storage` enabled looks like this, where `external_public_agent_ip` is the public ip of e.g. your AWS ELB.

options.json
```json
{
  "service": {
    "name": "/jupyter-notebook",
    "cmd": "export SPARK_CONF_SPARK_EXECUTORENV_CLASSPATH=\"spark.executorEnv.CLASSPATH=$(${HADOOP_HDFS_HOME}/bin/hadoop classpath --glob):${CLASSPATH}\" && export SPARK_CONF_SPARK_EXECUTORENV_LD_LIBRARY_PATH=\"spark.executorEnv.LD_LIBRARY_PATH=${LD_LIBRARY_PATH}\" && /usr/local/bin/start.sh ${CONDA_DIR}/bin/jupyter lab --notebook-dir=\"/mnt/mesos/sandbox\"",
    "cpus": 1,
    "force_pull": false,
    "gpu_support": {
      "enabled": false,
      "gpus": 0
    },
    "mem": 8192,
    "user": "nobody"
  },
  "oidc": {
    "enable_oidc": false,
    "oidc_discover_uri": "https://keycloak.example.com/auth/realms/Notebook/.well-known/openid-configuration",
    "oidc_redirect_uri": "/oidc-redirect-callback",
    "oidc_client_id": "Notebook",
    "oidc_client_secret": "b874f6e9-8f3f-41a6-a206-53e928d24fb1",
    "oidc_tls_verify": "no",
    "enable_windows": false,
    "oidc_use_email": false,
    "oidc_email": "user@example.com",
    "oidc_upn": "user007",
    "oidc_logout_path": "/logmeout",
    "oidc_post_logout_redirect_uri": "https://<VHOST>/<optional PATH_PREFIX>/<Service Name>",
    "oidc_use_spartan_resolver": true
  },
  "spark": {
    "enable_spark_monitor": true,
    "spark_master_url": "mesos://zk://zk-1.zk:2181,zk-2.zk:2181,zk-3.zk:2181,zk-4.zk:2181,zk-5.zk:2181/mesos",
    "spark_driver_cores": 2,
    "spark_driver_memory": "4g",
    "spark_driver_java_options": "\"-XX:+UseG1GC -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/mnt/mesos/sandbox\"",
    "spark_conf_spark_scheduler": "spark.scheduler.minRegisteredResourcesRatio=1.0",
    "spark_conf_cores_max": "spark.cores.max=5",
    "spark_conf_executor_cores": "spark.executor.cores=1",
    "spark_conf_executor_memory": "spark.executor.memory=4g",
    "spark_conf_executor_java_options": "spark.executor.extraJavaOptions=\"-XX:+UseG1GC -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/mnt/mesos/sandbox\"",
    "spark_conf_eventlog_enabled": "spark.eventLog.enabled=true",
    "spark_conf_eventlog_dir": "spark.eventLog.dir=s3a://your-dcos-aws/spark/history",
    "spark_conf_hadoop_fs_s3a_aws_credentials_provider": "spark.hadoop.fs.s3a.aws.credentials.provider=com.amazonaws.auth.InstanceProfileCredentialsProvider",
    "spark_conf_mesos_executor_docker_image": "spark.mesos.executor.docker.image=vishnumohan/spark-dcos:tfos",
    "spark_conf_mesos_executor_home": "spark.mesos.executor.home=/opt/spark",
    "spark_conf_mesos_containerizer": "spark.mesos.containerizer=mesos",
    "spark_conf_mesos_principle": "spark.mesos.principal=dev_jupyter",
    "spark_conf_mesos_role": "spark.mesos.role=dev-jupyter",
    "spark_conf_mesos_driver_labels": "spark.mesos.driver.labels=DCOS_SPACE:/dev/jupyter",
    "spark_conf_mesos_task_labels": "spark.mesos.task.labels=DCOS_SPACE:/dev/jupyter",
    "spark_conf_mesos_conf_base64": "spark.mesos.driverEnv.SPARK_MESOS_KRB5_CONF_BASE64=W2xpYmRlZmF1bHRzXQoJZGVmYXVsdF9yZWFsbSA9IEFUSEVOQS5NSVQuRURVCgpbcmVhbG1zXQojIHVzZSAia2RjID0gLi4uIiBpZiByZWFsbSBhZG1pbnMgaGF2ZW4ndCBwdXQgU1JWIHJlY29yZHMgaW50byBETlMKCUFUSEVOQS5NSVQuRURVID0gewoJCWFkbWluX3NlcnZlciA9IGtlcmJlcm9zLm1pdC5lZHUKCX0KCUFORFJFVy5DTVUuRURVID0gewoJCWFkbWluX3NlcnZlciA9IGtkYy0wMS5hbmRyZXcuY211LmVkdQoJfQoKW2RvbWFpbl9yZWFsbV0KCW1pdC5lZHUgPSBBVEhFTkEuTUlULkVEVQoJY3NhaWwubWl0LmVkdSA9IENTQUlMLk1JVC5FRFUKCS51Y3NjLmVkdSA9IENBVFMuVUNTQy5FRFUKCltsb2dnaW5nXQojCWtkYyA9IENPTlNPTEUK",
    "spark_conf_executor_conf_base64": "spark.executorEnv.SPARK_MESOS_KRB5_CONF_BASE64=W2xpYmRlZmF1bHRzXQoJZGVmYXVsdF9yZWFsbSA9IEFUSEVOQS5NSVQuRURVCgpbcmVhbG1zXQojIHVzZSAia2RjID0gLi4uIiBpZiByZWFsbSBhZG1pbnMgaGF2ZW4ndCBwdXQgU1JWIHJlY29yZHMgaW50byBETlMKCUFUSEVOQS5NSVQuRURVID0gewoJCWFkbWluX3NlcnZlciA9IGtlcmJlcm9zLm1pdC5lZHUKCX0KCUFORFJFVy5DTVUuRURVID0gewoJCWFkbWluX3NlcnZlciA9IGtkYy0wMS5hbmRyZXcuY211LmVkdQoJfQoKW2RvbWFpbl9yZWFsbV0KCW1pdC5lZHUgPSBBVEhFTkEuTUlULkVEVQoJY3NhaWwubWl0LmVkdSA9IENTQUlMLk1JVC5FRFUKCS51Y3NjLmVkdSA9IENBVFMuVUNTQy5FRFUKCltsb2dnaW5nXQojCWtkYyA9IENPTlNPTEUK",
    "spark_conf_executor_krb5_config": "spark.executorEnv.KRB5_CONFIG=/mnt/mesos/sandbox/krb5.conf",
    "spark_conf_executor_java_home": "spark.executorEnv.JAVA_HOME=/opt/jdk",
    "spark_conf_executor_hadoop_hdfs_home": "spark.executorEnv.HADOOP_HDFS_HOME=/opt/hadoop",
    "spark_conf_executor_hadoop_opts": "spark.executorEnv.HADOOP_OPTS=\"-Djava.library.path=/opt/hadoop/lib/native -Djava.security.krb5.conf=/mnt/mesos/sandbox/krb5.conf\"",
    "spark_conf_mesos_executor_docker_forcepullimage": "spark.mesos.executor.docker.forcePullImage=true",
    "spark_conf_mesos_uri": "spark.mesos.uris=http://api.devhdfs.marathon.l4lb.thisdcos.directory/v1/endpoints/hdfs-site.xml,http://api.devhdfs.marathon.l4lb.thisdcos.directory/v1/endpoints/core-site.xml",
    "spark_mesos_conf_krb5_config": "W2xpYmRlZmF1bHRzXQoJZGVmYXVsdF9yZWFsbSA9IEFUSEVOQS5NSVQuRURVCgpbcmVhbG1zXQojIHVzZSAia2RjID0gLi4uIiBpZiByZWFsbSBhZG1pbnMgaGF2ZW4ndCBwdXQgU1JWIHJlY29yZHMgaW50byBETlMKCUFUSEVOQS5NSVQuRURVID0gewoJCWFkbWluX3NlcnZlciA9IGtlcmJlcm9zLm1pdC5lZHUKCX0KCUFORFJFVy5DTVUuRURVID0gewoJCWFkbWluX3NlcnZlciA9IGtkYy0wMS5hbmRyZXcuY211LmVkdQoJfQoKW2RvbWFpbl9yZWFsbV0KCW1pdC5lZHUgPSBBVEhFTkEuTUlULkVEVQoJY3NhaWwubWl0LmVkdSA9IENTQUlMLk1JVC5FRFUKCS51Y3NjLmVkdSA9IENBVFMuVUNTQy5FRFUKCltsb2dnaW5nXQojCWtkYyA9IENPTlNPTEUK",
    "spark_user": "nobody"
  },
  "storage": {
    "hdfs_support": false,
    "hdfs_core_url": "http://api.devhdfs.marathon.l4lb.thisdcos.directory/v1/endpoints/core-site.xml",
    "hdfs_site_url": "http://api.devhdfs.marathon.l4lb.thisdcos.directory/v1/endpoints/hdfs-site.xml",
    "persistence": {
      "host_volume_size": 4000,
      "enable": true
    }
  },
  "networking": {
    "cni_support": {
      "enabled": false
    },
    "external_access": {
      "enabled": true,
      "external_public_agent_ip": "jupyter-publicslav-a9w05wgw3px4-959689447.us-west-2.elb.amazonaws.com"
    }
  },
  "environment": {
    "secrets": false,
    "service_credential": "dev/jupyter/serviceCredential",
    "aws_region": "us-east-1",
    "conda_envs_path": "/mnt/mesos/sandbox/conda/envs:/opt/conda/envs",
    "conda_pkgs_dir": "/mnt/mesos/sandbox/conda/pkgs:/opt/conda/pkgs",
    "dcos_dir": "/mnt/mesos/sandbox/.dcos",
    "hadoop_conf_dir": "/mnt/mesos/sandbox",
    "home": "/mnt/mesos/sandbox",
    "java_opts": "\"-XX:+UseG1GC -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/mnt/mesos/sandbox\"",
    "jupyter_config_dir": "/mnt/mesos/sandbox/.jupyter",
    "jupyter_password": "somepassword",
    "jupyter_runtime_dir": "/mnt/mesos/sandbox/.local/share/jupyter/runtime",
    "nginx_log_level": "warn",
    "s3_endpoint": "s3.us-east-1.amazonaws.com",
    "s3_https": 1,
    "s3_ssl": 1,
    "start_dask_distributed": true,
    "start_ray_head_node": true,
    "user": "nobody",
    "tensorboard_logdir": "/mnt/mesos/sandbox",
    "term": "xterm-256color"
  }
}
```

You can create this `options.json` manually or via the UI installation.

#### External Access

In order to access your `Jupyter` service from outside the cluster you need to have the `Marathon-LB` service installed. 

When enabling `external_access` you point via the `EXTERNAL_PUBLIC_AGENT_IP` field to your public agent DNS name. Please be sure to only use the DNS name without any leading `http://` or `https://`.

#### Persistent Storage

When persistent storage is enabled you will find in your `Jupyter` container under `/mnt/mesos/sandbox` the `persistent_data` folder.

Now when accessing your `Jupyter` service and uploading files to your `persistent_data` folder, e.g. notebooks, they are persistent stored.

## Use Jupyter and BeakerX 

By accessing Jupyter under the assigned host and port you are now able to authenticate and try the various [tutorials and examples](http://nbviewer.jupyter.org/github/twosigma/beakerx/blob/master/StartHere.ipynb).

## Further reading

### Uninstall Jupyter

If your service name was e.g. `/jupyter-notebook` use the following commands to shut down and delete your Jupyter service:

```bash
$ dcos package uninstall jupyter --app-id=/jupyter-notebook
Uninstalled package [jupyter] version [1.11.3-0.32.1]
Service uninstalled. Note that any persisting data will be automatically removed from the agent where the service was deployed.
```

### Configuration options

There are a number of configuration options, which can be specified in the following
way:

```bash
$ dcos package install --config=<options> jupyter
```

where `options` is the path to a JSON file, e.g. `options.json`. For a list of possible
attribute values see

```bash
$ dcos package describe --config jupyter
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

- [DC/OS Jupyter Service](https://github.com/dcos-labs/dcos-jupyter-service)
- [Website BeakerX](http://beakerx.com)
- [Github BeakerX](https://github.com/twosigma/beakerx)


### Release Notes and Versions

The initial release version was [v1.11.3-0.32.1](https://github.com/dcos-labs/dcos-jupyter-service/tree/v1.11.3-0.32.1) and will be updated over time. A release history and the latest release can be found [here](https://github.com/dcos-labs/dcos-jupyter-service/releases). 

| Version | Release Notes | Github |
|----------|----------|-------|
| `v1.11.3-0.32.1` | [here](https://github.com/dcos-labs/dcos-jupyter-service/releases/tag/v1.11.3-0.32.1) | [here](https://github.com/dcos-labs/dcos-jupyter-service/tree/v1.11.3-0.32.1)  |

#### Package list `v1.11.3-0.32.1`

The `base` version consists of additionally installed [packages](https://github.com/dcos-labs/dcos-jupyter-service/blob/master/beakerx-root-conda-base-env.yml) tailored for Data Scientists needs:

```bash
# packages in environment at /opt/conda:
#
# Name                    Version                   Build  Channel
absl-py                   0.2.2                      py_0    conda-forge
alembic                   0.9.9                      py_0    conda-forge
altair                    2.1.0                      py_0    conda-forge
appdirs                   1.4.3                      py_1    conda-forge
arrow-cpp                 0.9.0            py36h1ae9da6_7    conda-forge
asn1crypto                0.24.0                   py36_0    conda-forge
astor                     0.6.2                      py_0    conda-forge
async_generator           1.9                           0    conda-forge
atari-py                  0.1.1                     <pip>
atomicwrites              1.1.5                    py36_0    conda-forge
attrs                     18.1.0                     py_1    conda-forge
automat                   0.7.0                    py36_0    conda-forge
awscli                    1.15.53                  py36_0    conda-forge
backcall                  0.1.0                      py_0    conda-forge
bazel                     0.15.0                        0    conda-forge
beakerx                   1.0.0                    py36_1    conda-forge
beautifulsoup4            4.6.0                    py36_0    conda-forge
blas                      1.1                    openblas    conda-forge
bleach                    1.5.0                    py36_0    conda-forge
bokeh                     0.12.16                  py36_0    conda-forge
boost-cpp                 1.66.0                        1    conda-forge
boto3                     1.7.52                     py_0    conda-forge
botocore                  1.10.52                    py_0    conda-forge
bottleneck                1.2.1            py36h7eb728f_1    conda-forge
bs4                       0.0.1                     <pip>
bzip2                     1.0.6                         1    conda-forge
ca-certificates           2018.4.16                     0    conda-forge
cairo                     1.14.10                       0    conda-forge
certifi                   2018.4.16                py36_0    conda-forge
cffi                      1.11.5                   py36_0    conda-forge
chardet                   3.0.4                      py_1    conda-forge
click                     6.7                        py_1    conda-forge
cloudpickle               0.5.3                      py_0    conda-forge
colorama                  0.3.9                      py_1    conda-forge
conda                     4.5.6                    py36_0    conda-forge
conda-env                 2.6.0                         0    conda-forge
configurable-http-proxy   3.1.0                   node8_1    conda-forge
constantly                15.1.0                     py_0    conda-forge
cryptography              2.2.1            py36hdffb7b8_1    conda-forge
curl                      7.60.0                        0    conda-forge
cycler                    0.10.0                     py_1    conda-forge
cython                    0.28.4           py36hfc679d8_0    conda-forge
cytoolz                   0.9.0.1                  py36_0    conda-forge
dask                      0.18.1                     py_0    conda-forge
dask-core                 0.18.1                     py_0    conda-forge
dask-glm                  0.1.0                         0    conda-forge
dask-ml                   0.7.0            py36h470a237_0    conda-forge
dask-tensorflow           0.0.2                      py_0    conda-forge
dask-xgboost              0.1.5                      py_0    conda-forge
dbus                      1.13.0               h3a4f0e9_0    conda-forge
decorator                 4.3.0                      py_0    conda-forge
distributed               1.22.0                   py36_0    conda-forge
docutils                  0.14                     py36_0    conda-forge
empyrical                 0.3.4                         0    conda-forge
entrypoints               0.2.3                    py36_1    conda-forge
expat                     2.2.5                hfc679d8_1    conda-forge
flake8                    3.5.0                    py36_0    conda-forge
flatbuffers               2015.12.22.1              <pip>
fontconfig                2.12.6                        0    conda-forge
freetype                  2.8.1                         0    conda-forge
funcsigs                  1.0.2                      py_2    conda-forge
future                    0.16.0                   py36_0    conda-forge
gast                      0.2.0                      py_0    conda-forge
gettext                   0.19.8.1                      0    conda-forge
glib                      2.55.0                        0    conda-forge
gmp                       6.1.2                hfc679d8_0    conda-forge
graphite2                 1.3.11               hfc679d8_0    conda-forge
grpcio                    1.12.1           py36hdbcaa40_0    defaults
gsl                       2.4             blas_openblas_0  [blas_openblas]  conda-forge
gst-plugins-base          1.8.0                         0    conda-forge
gstreamer                 1.8.0                         1    conda-forge
gym                       0.10.5                    <pip>
h5py                      2.8.0            py36hb794570_1    conda-forge
harfbuzz                  1.7.6                         0    conda-forge
hdf5                      1.10.2                        0    conda-forge
heapdict                  1.0.0                    py36_0    conda-forge
horovod                   0.13.7                    <pip>
html5lib                  0.9999999                py36_0    conda-forge
hyperlink                 17.3.1                     py_0    conda-forge
icu                       58.2                 hfc679d8_0    conda-forge
idna                      2.7                        py_1    conda-forge
incremental               17.5.0                     py_0    conda-forge
invoke                    1.0.0                    py36_0    conda-forge
ipykernel                 4.8.2                    py36_0    conda-forge
ipython                   6.4.0                    py36_0    conda-forge
ipython_genutils          0.2.0                      py_1    conda-forge
ipywidgets                7.2.1                    py36_1    conda-forge
jedi                      0.12.0                   py36_0    conda-forge
jinja2                    2.10                     py36_0    conda-forge
jmespath                  0.9.3                    py36_0    conda-forge
joblib                    0.12                       py_0    conda-forge
jpeg                      9c                   h470a237_0    conda-forge
jsonschema                2.6.0                    py36_1    conda-forge
jupyter_client            5.2.3                    py36_0    conda-forge
jupyter_contrib_core      0.3.3                    py36_1    conda-forge
jupyter_contrib_nbextensions 0.5.0                    py36_0    conda-forge
jupyter_core              4.4.0                      py_0    conda-forge
jupyter_highlight_selected_word 0.2.0                    py36_0    conda-forge
jupyter_latex_envs        1.4.4                    py36_0    conda-forge
jupyter_nbextensions_configurator 0.4.0                    py36_0    conda-forge
jupyterhub                0.9.0                    py36_0    conda-forge
jupyterlab                0.32.1                   py36_0    conda-forge
jupyterlab-github         0.6.0                     <pip>
jupyterlab_launcher       0.10.5                   py36_0    conda-forge
keras                     2.1.6                    py36_0    conda-forge
kiwisolver                1.0.1                    py36_1    conda-forge
knowledgelab              0.0.1                     <pip>
krb5                      1.14.6                        0    conda-forge
libcurl                   7.60.0               h1ad7b7a_0    defaults
libedit                   3.1.20170329                  0    conda-forge
libffi                    3.2.1                         3    conda-forge
libgcc                    7.2.0                h69d50b8_2    defaults
libgcc-ng                 7.2.0                hdf63c60_3    defaults
libgcrypt                 1.8.3                hfc679d8_0    conda-forge
libgfortran               3.0.0                         1    defaults
libgpg-error              1.31                 hf484d3e_0    conda-forge
libgpuarray               0.7.6                         0    conda-forge
libgsasl                  1.8.0                         2    conda-forge
libhdfs3                  2.3                           3    conda-forge
libiconv                  1.15                 h470a237_1    conda-forge
libntlm                   1.4                  h470a237_1    conda-forge
libpng                    1.6.34               ha92aebf_1    conda-forge
libprotobuf               3.5.2                hd28b015_1    conda-forge
libsodium                 1.0.16                        0    conda-forge
libssh2                   1.8.0                h5b517e9_2    conda-forge
libstdcxx-ng              7.2.0                hdf63c60_3    defaults
libtiff                   4.0.9                he6b73bb_1    conda-forge
libuuid                   1.0.3                         1    conda-forge
libxcb                    1.13                 h470a237_0    conda-forge
libxml2                   2.9.8                h422b904_1    conda-forge
libxslt                   1.1.32               h88dbc4e_1    conda-forge
locket                    0.2.0                    py36_1    conda-forge
lxml                      4.2.2            py36hc9114bc_0    conda-forge
lz4                       2.0.2                     <pip>
mako                      1.0.7                    py36_0    conda-forge
markdown                  2.6.11                     py_0    conda-forge
markupsafe                1.0                      py36_0    conda-forge
matplotlib                2.2.2                    py36_1    conda-forge
maven                     3.5.0                         0    conda-forge
mccabe                    0.6.1                      py_1    conda-forge
mistune                   0.8.3                    py36_1    conda-forge
more-itertools            4.2.0                      py_0    conda-forge
mpi                       1.0                       mpich    conda-forge
mpi4py                    3.0.0              py36_mpich_2    conda-forge
mpich                     3.2.1                h26a2512_4    conda-forge
msgpack-python            0.5.6            py36h2d50403_2    conda-forge
multipledispatch          0.5.0                    py36_0    conda-forge
nbconvert                 5.3.1                      py_1    conda-forge
nbformat                  4.4.0                    py36_0    conda-forge
ncurses                   5.9                          10    conda-forge
nodejs                    8.11.1               hf484d3e_0    defaults
notebook                  5.5.0                    py36_0    conda-forge
numpy                     1.14.5          py36_blas_openblashd3ea46f_201  [blas_openblas]  conda-forge
olefile                   0.45.1                     py_1    conda-forge
openblas                  0.2.20                        8    conda-forge
opencv-python             3.4.1.15                  <pip>
openssl                   1.0.2o                        0    conda-forge
packaging                 17.1                       py_0    conda-forge
pamela                    0.3.0                    py36_0    conda-forge
pandas                    0.23.3                   py36_0    conda-forge
pandas-datareader         0.6.0                    py36_0    conda-forge
pandoc                    2.2.1                         0    conda-forge
pandocfilters             1.4.2                    py36_0    conda-forge
pango                     1.40.14                       0    conda-forge
parquet-cpp               1.4.0                h83d4a3d_1    conda-forge
parso                     0.3.0                      py_0    conda-forge
partd                     0.3.8                      py_1    conda-forge
patsy                     0.5.0                    py36_0    conda-forge
pcre                      8.39                          0    conda-forge
pep8                      1.7.1                      py_0    conda-forge
pexpect                   4.6.0                    py36_0    conda-forge
pickleshare               0.7.4                    py36_0    conda-forge
pillow                    5.2.0                    py36_0    conda-forge
pip                       10.0.1                    <pip>
pip                       9.0.3                    py36_0    conda-forge
pixman                    0.34.0                        2    conda-forge
pluggy                    0.6.0                      py_0    conda-forge
prometheus_client         0.2.0                    py36_0    conda-forge
prompt_toolkit            1.0.15                   py36_0    conda-forge
protobuf                  3.5.2                    py36_0    conda-forge
psutil                    5.4.6                    py36_0    conda-forge
ptyprocess                0.6.0                    py36_0    conda-forge
py                        1.5.4                      py_0    conda-forge
py4j                      0.10.7                   py36_0    conda-forge
pyarrow                   0.9.0            py36hfc679d8_2    conda-forge
pyasn1                    0.4.3                      py_0    conda-forge
pyasn1-modules            0.2.1                      py_0    conda-forge
pycodestyle               2.3.1                    py36_0    conda-forge
pycosat                   0.6.3                    py36_0    conda-forge
pycparser                 2.18                     py36_0    conda-forge
pycurl                    7.43.0.2         py36hb7f436b_0    defaults
pyflakes                  1.6.0                    py36_0    conda-forge
pyfolio                   0.8.0                      py_0    conda-forge
pyglet                    1.3.2                     <pip>
pygments                  2.2.0                      py_1    conda-forge
pygpu                     0.7.6                    py36_0    conda-forge
pyhamcrest                1.9.0                    py36_1    conda-forge
pymc3                     3.4.1                    py36_0    conda-forge
PyOpenGL                  3.1.0                     <pip>
pyopenssl                 18.0.0                   py36_0    conda-forge
pyparsing                 2.2.0                      py_1    conda-forge
pysocks                   1.6.8                    py36_1    conda-forge
pytest                    3.6.2                    py36_0    conda-forge
python                    3.6.5                         1    conda-forge
python-dateutil           2.7.3                      py_0    conda-forge
python-editor             1.0.3                    py36_0    conda-forge
python-oauth2             1.0.1                    py36_0    conda-forge
python-snappy             0.5.3            py36h00d4201_0    conda-forge
pytz                      2018.5                     py_0    conda-forge
pyyaml                    3.12                     py36_1    conda-forge
pyzmq                     17.0.0                   py36_4    conda-forge
r-base                    3.4.1                         4    conda-forge
r-base64enc               0.1_3                  r3.4.1_0    conda-forge
r-crayon                  1.3.4                  r3.4.1_0    conda-forge
r-digest                  0.6.15                 r3.4.1_0    conda-forge
r-evaluate                0.10.1                 r3.4.1_0    conda-forge
r-glue                    1.2.0                  r3.4.1_0    conda-forge
r-htmltools               0.3.6                  r3.4.1_0    conda-forge
r-irdisplay               0.4.4                  r3.4.1_0    conda-forge
r-irkernel                0.8.12                   r341_0    conda-forge
r-jsonlite                1.5                    r3.4.1_0    conda-forge
r-magrittr                1.5                    r3.4.1_0    conda-forge
r-pbdzmq                  0.3_2                  r3.4.1_0    conda-forge
r-r6                      2.2.2                  r3.4.1_0    conda-forge
r-rcpp                    0.12.15                r3.4.1_0    conda-forge
r-repr                    0.15                     r341_0    conda-forge
r-stringi                 1.2.3                    r341_0    conda-forge
r-stringr                 1.3.1                    r341_0    conda-forge
r-uuid                    0.1_2                  r3.4.1_0    conda-forge
ray                       0.5.0                     <pip>
readline                  7.0                           0    conda-forge
redis                     2.10.6                    <pip>
requests                  2.19.1                   py36_0    conda-forge
requests-file             1.4.3                    py36_0    defaults
requests-ftp              0.3.1                    py36_0    conda-forge
rsa                       3.4.2                    py36_0    conda-forge
ruamel_yaml               0.15.42          py36h470a237_0    conda-forge
s3fs                      0.1.5                      py_0    conda-forge
s3transfer                0.1.13                   py36_0    conda-forge
scikit-learn              0.19.1          py36_blas_openblas_201  [blas_openblas]  conda-forge
scipy                     1.1.0           py36_blas_openblas_200  [blas_openblas]  conda-forge
seaborn                   0.8.1                    py36_0    conda-forge
send2trash                1.5.0                      py_0    conda-forge
service_identity          17.0.0                     py_0    conda-forge
setuptools                39.2.0                   py36_0    conda-forge
simplegeneric             0.8.1                      py_1    conda-forge
sip                       4.18                     py36_1    conda-forge
six                       1.11.0                   py36_1    conda-forge
snappy                    1.1.7                hfc679d8_2    conda-forge
sortedcontainers          2.0.4                    py36_0    conda-forge
sparkmonitor              0.0.9                     <pip>
sqlalchemy                1.2.9                    py36_0    conda-forge
sqlite                    3.20.1                        2    conda-forge
statsmodels               0.9.0                    py36_0    conda-forge
tblib                     1.3.2                    py36_0    conda-forge
tensorboard               1.8.0                    py36_1    conda-forge
tensorflow                1.8.0                    py36_1    conda-forge
tensorflow-hub            0.1.0                     <pip>
tensorflowonspark         1.3.0                     <pip>
termcolor                 1.1.0                      py_2    conda-forge
terminado                 0.8.1                    py36_0    conda-forge
testpath                  0.3.1                    py36_0    conda-forge
theano                    1.0.2                    py36_0    conda-forge
tk                        8.6.7                         0    conda-forge
toolz                     0.9.0                      py_0    conda-forge
toree                     0.2.0                     <pip>
tornado                   5.0.2                    py36_0    conda-forge
tqdm                      4.23.4                     py_0    conda-forge
traitlets                 4.3.2                    py36_0    conda-forge
twisted                   18.4.0           py36h470a237_0    conda-forge
typing                    3.6.4                    py36_0    conda-forge
urllib3                   1.23                     py36_0    conda-forge
wcwidth                   0.1.7                      py_1    conda-forge
webencodings              0.5                      py36_0    conda-forge
werkzeug                  0.14.1                     py_0    conda-forge
wheel                     0.31.1                   py36_0    conda-forge
widgetsnbextension        3.2.1                    py36_0    conda-forge
wrapt                     1.10.11                  py36_0    conda-forge
xgboost                   0.72                     py36_0    conda-forge
xlrd                      1.1.0                      py_2    conda-forge
xorg-libxau               1.0.8                h470a237_5    conda-forge
xorg-libxdmcp             1.1.2                h470a237_6    conda-forge
xz                        5.2.3                         0    conda-forge
yaml                      0.1.7                         0    conda-forge
yapf                      0.22.0                     py_0    conda-forge
zeromq                    4.2.5                hfc679d8_3    conda-forge
zict                      0.1.3                      py_0    conda-forge
zlib                      1.2.11               h470a237_3    conda-forge
zope.interface            4.5.0            py36h470a237_0    conda-forge
```

#### Package list `v1.11.3-0.32.1` GPU version
The `GPU` version extends the `base` package with:

```bash
# packages in environment at /opt/conda:
#
# Name                    Version                   Build  Channel
absl-py                   0.2.2                      py_0    conda-forge
alembic                   0.9.9                      py_0    conda-forge
altair                    2.1.0                      py_0    conda-forge
appdirs                   1.4.3                      py_1    conda-forge
arrow-cpp                 0.9.0            py36h1ae9da6_7    conda-forge
asn1crypto                0.24.0                   py36_0    conda-forge
astor                     0.6.2                      py_0    conda-forge
async_generator           1.9                           0    conda-forge
atari-py                  0.1.1                     <pip>
atomicwrites              1.1.5                    py36_0    conda-forge
attrs                     18.1.0                     py_1    conda-forge
automat                   0.7.0                    py36_0    conda-forge
awscli                    1.15.53                  py36_0    conda-forge
backcall                  0.1.0                      py_0    conda-forge
bazel                     0.15.0                        0    conda-forge
beakerx                   1.0.0                    py36_1    conda-forge
beautifulsoup4            4.6.0                    py36_0    conda-forge
blas                      1.1                    openblas    conda-forge
bleach                    1.5.0                    py36_0    conda-forge
bokeh                     0.12.16                  py36_0    conda-forge
boost-cpp                 1.66.0                        1    conda-forge
boto3                     1.7.52                     py_0    conda-forge
botocore                  1.10.52                    py_0    conda-forge
bottleneck                1.2.1            py36h7eb728f_1    conda-forge
bs4                       0.0.1                     <pip>
bzip2                     1.0.6                         1    conda-forge
ca-certificates           2018.4.16                     0    conda-forge
cairo                     1.14.12              he56eebe_1    conda-forge
certifi                   2018.4.16                py36_0    conda-forge
cffi                      1.11.5                   py36_0    conda-forge
chardet                   3.0.4                      py_1    conda-forge
click                     6.7                        py_1    conda-forge
cloudpickle               0.5.3                      py_0    conda-forge
colorama                  0.3.9                      py_1    conda-forge
conda                     4.5.6                    py36_0    conda-forge
conda-env                 2.6.0                         0    conda-forge
configurable-http-proxy   3.1.0                   node8_1    conda-forge
constantly                15.1.0                     py_0    conda-forge
cryptography              2.2.1            py36hdffb7b8_1    conda-forge
cuda90                    1.0                  h6433d27_0    pytorch
curl                      7.60.0                        0    conda-forge
cycler                    0.10.0                     py_1    conda-forge
cython                    0.28.4           py36hfc679d8_0    conda-forge
cytoolz                   0.9.0.1                  py36_0    conda-forge
dask                      0.18.1                     py_0    conda-forge
dask-core                 0.18.1                     py_0    conda-forge
dask-glm                  0.1.0                         0    conda-forge
dask-ml                   0.7.0            py36h470a237_0    conda-forge
dask-tensorflow           0.0.2                      py_0    conda-forge
dask-xgboost              0.1.5                      py_0    conda-forge
dbus                      1.13.0               h3a4f0e9_0    conda-forge
decorator                 4.3.0                      py_0    conda-forge
distributed               1.22.0                   py36_0    conda-forge
docutils                  0.14                     py36_0    conda-forge
empyrical                 0.3.4                         0    conda-forge
entrypoints               0.2.3                    py36_1    conda-forge
expat                     2.2.5                hfc679d8_1    conda-forge
flake8                    3.5.0                    py36_0    conda-forge
flatbuffers               2015.12.22.1              <pip>
fontconfig                2.13.0                        1    conda-forge
freetype                  2.8.1                         0    conda-forge
funcsigs                  1.0.2                      py_2    conda-forge
future                    0.16.0                   py36_0    conda-forge
gast                      0.2.0                      py_0    conda-forge
gettext                   0.19.8.1                      0    conda-forge
glib                      2.55.0                        0    conda-forge
gmp                       6.1.2                hfc679d8_0    conda-forge
graphite2                 1.3.11               hfc679d8_0    conda-forge
grpcio                    1.12.1           py36hdbcaa40_0    defaults
gsl                       2.4             blas_openblas_0  [blas_openblas]  conda-forge
gst-plugins-base          1.8.0                         0    conda-forge
gstreamer                 1.8.0                         1    conda-forge
gym                       0.10.5                    <pip>
h5py                      2.8.0            py36hb794570_1    conda-forge
harfbuzz                  1.7.6                         0    conda-forge
hdf5                      1.10.2                        0    conda-forge
heapdict                  1.0.0                    py36_0    conda-forge
horovod                   0.13.7                    <pip>
html5lib                  0.9999999                py36_0    conda-forge
hyperlink                 17.3.1                     py_0    conda-forge
icu                       58.2                 hfc679d8_0    conda-forge
idna                      2.7                        py_1    conda-forge
incremental               17.5.0                     py_0    conda-forge
intel-openmp              2018.0.3                      0    defaults
invoke                    1.0.0                    py36_0    conda-forge
ipykernel                 4.8.2                    py36_0    conda-forge
ipython                   6.4.0                    py36_0    conda-forge
ipython_genutils          0.2.0                      py_1    conda-forge
ipywidgets                7.2.1                    py36_1    conda-forge
jedi                      0.12.0                   py36_0    conda-forge
jinja2                    2.10                     py36_0    conda-forge
jmespath                  0.9.3                    py36_0    conda-forge
joblib                    0.12                       py_0    conda-forge
jpeg                      9c                   h470a237_0    conda-forge
jsonschema                2.6.0                    py36_1    conda-forge
jupyter_client            5.2.3                    py36_0    conda-forge
jupyter_contrib_core      0.3.3                    py36_1    conda-forge
jupyter_contrib_nbextensions 0.5.0                    py36_0    conda-forge
jupyter_core              4.4.0                      py_0    conda-forge
jupyter_highlight_selected_word 0.2.0                    py36_0    conda-forge
jupyter_latex_envs        1.4.4                    py36_0    conda-forge
jupyter_nbextensions_configurator 0.4.0                    py36_0    conda-forge
jupyterhub                0.9.0                    py36_0    conda-forge
jupyterlab                0.32.1                   py36_0    conda-forge
jupyterlab-github         0.6.0                     <pip>
jupyterlab_launcher       0.10.5                   py36_0    conda-forge
keras                     2.1.6                    py36_0    conda-forge
kiwisolver                1.0.1                    py36_1    conda-forge
knowledgelab              0.0.1                     <pip>
krb5                      1.14.6                        0    conda-forge
libcurl                   7.60.0               h1ad7b7a_0    defaults
libedit                   3.1.20170329                  0    conda-forge
libffi                    3.2.1                         3    conda-forge
libgcc                    7.2.0                h69d50b8_2    defaults
libgcc-ng                 7.2.0                hdf63c60_3    defaults
libgcrypt                 1.8.3                hfc679d8_0    conda-forge
libgfortran               3.0.0                         1    defaults
libgfortran-ng            7.2.0                hdf63c60_3    defaults
libgpg-error              1.31                 hf484d3e_0    conda-forge
libgpuarray               0.7.6                         0    conda-forge
libgsasl                  1.8.0                         2    conda-forge
libhdfs3                  2.3                           3    conda-forge
libiconv                  1.15                 h470a237_1    conda-forge
libntlm                   1.4                  h470a237_1    conda-forge
libopenblas               0.2.20               h9ac9557_7    defaults
libpng                    1.6.34               ha92aebf_1    conda-forge
libprotobuf               3.5.2                hd28b015_1    conda-forge
libsodium                 1.0.16                        0    conda-forge
libssh2                   1.8.0                h5b517e9_2    conda-forge
libstdcxx-ng              7.2.0                hdf63c60_3    defaults
libtiff                   4.0.9                he6b73bb_1    conda-forge
libuuid                   1.0.3                         1    conda-forge
libxcb                    1.13                 h470a237_0    conda-forge
libxml2                   2.9.8                h422b904_1    conda-forge
libxslt                   1.1.32               h88dbc4e_1    conda-forge
llvmlite                  0.23.0                   py36_1    conda-forge
locket                    0.2.0                    py36_1    conda-forge
lxml                      4.2.2            py36hc9114bc_0    conda-forge
lz4                       2.0.2                     <pip>
mako                      1.0.7                    py36_0    conda-forge
markdown                  2.6.11                     py_0    conda-forge
markupsafe                1.0                      py36_0    conda-forge
matplotlib                2.2.2                    py36_1    conda-forge
maven                     3.5.0                         0    conda-forge
mccabe                    0.6.1                      py_1    conda-forge
mistune                   0.8.3                    py36_1    conda-forge
mkl                       2018.0.3                      1    defaults
mkl_fft                   1.0.2                    py36_0    conda-forge
mkl_random                1.0.1                    py36_0    conda-forge
more-itertools            4.2.0                      py_0    conda-forge
mpi                       1.0                       mpich    conda-forge
mpi4py                    3.0.0              py36_mpich_2    conda-forge
mpich                     3.2.1                h26a2512_4    conda-forge
msgpack-python            0.5.6            py36h2d50403_2    conda-forge
multipledispatch          0.5.0                    py36_0    conda-forge
nbconvert                 5.3.1                      py_1    conda-forge
nbformat                  4.4.0                    py36_0    conda-forge
ncurses                   5.9                          10    conda-forge
ninja                     1.8.2                h2d50403_1    conda-forge
nodejs                    8.10.0                        0    conda-forge
notebook                  5.5.0                    py36_0    conda-forge
numba                     0.38.1                   py36_0    conda-forge
numpy                     1.14.5          py36_blas_openblashd3ea46f_201  [blas_openblas]  conda-forge
numpy-base                1.14.3           py36h0ea5e3f_1    defaults
olefile                   0.45.1                     py_1    conda-forge
openblas                  0.2.20                        8    conda-forge
opencv-python             3.4.1.15                  <pip>
openssl                   1.0.2o                        0    conda-forge
packaging                 17.1                       py_0    conda-forge
pamela                    0.3.0                    py36_0    conda-forge
pandas                    0.23.3                   py36_0    conda-forge
pandas-datareader         0.6.0                    py36_0    conda-forge
pandoc                    2.2.1                         0    conda-forge
pandocfilters             1.4.2                    py36_0    conda-forge
pango                     1.40.14              hd50be51_1    conda-forge
parquet-cpp               1.4.0                h83d4a3d_1    conda-forge
parso                     0.3.0                      py_0    conda-forge
partd                     0.3.8                      py_1    conda-forge
patsy                     0.5.0                    py36_0    conda-forge
pcre                      8.39                          0    conda-forge
pep8                      1.7.1                      py_0    conda-forge
pexpect                   4.6.0                    py36_0    conda-forge
pickleshare               0.7.4                    py36_0    conda-forge
pillow                    5.2.0                    py36_0    conda-forge
pip                       10.0.1                    <pip>
pip                       9.0.3                    py36_0    conda-forge
pixman                    0.34.0                        2    conda-forge
pluggy                    0.6.0                      py_0    conda-forge
prometheus_client         0.2.0                    py36_0    conda-forge
prompt_toolkit            1.0.15                   py36_0    conda-forge
protobuf                  3.5.2                    py36_0    conda-forge
psutil                    5.4.6                    py36_0    conda-forge
ptyprocess                0.6.0                    py36_0    conda-forge
py                        1.5.4                      py_0    conda-forge
py4j                      0.10.7                   py36_0    conda-forge
pyarrow                   0.9.0            py36hfc679d8_2    conda-forge
pyasn1                    0.4.3                      py_0    conda-forge
pyasn1-modules            0.2.1                      py_0    conda-forge
pycodestyle               2.3.1                    py36_0    conda-forge
pycosat                   0.6.3                    py36_0    conda-forge
pycparser                 2.18                     py36_0    conda-forge
pycurl                    7.43.0.2         py36hb7f436b_0    defaults
pyflakes                  1.6.0                    py36_0    conda-forge
pyfolio                   0.8.0                      py_0    conda-forge
pyglet                    1.3.2                     <pip>
pygments                  2.2.0                      py_1    conda-forge
pygpu                     0.7.6                    py36_0    conda-forge
pyhamcrest                1.9.0                    py36_1    conda-forge
pymc3                     3.4.1                    py36_0    conda-forge
PyOpenGL                  3.1.0                     <pip>
pyopenssl                 18.0.0                   py36_0    conda-forge
pyparsing                 2.2.0                      py_1    conda-forge
pysocks                   1.6.8                    py36_1    conda-forge
pytest                    3.6.2                    py36_0    conda-forge
python                    3.6.5                         1    conda-forge
python-dateutil           2.7.3                      py_0    conda-forge
python-editor             1.0.3                    py36_0    conda-forge
python-oauth2             1.0.1                    py36_0    conda-forge
python-snappy             0.5.3            py36h00d4201_0    conda-forge
pytorch                   0.4.0           py36_cuda9.0.176_cudnn7.1.2_1  [cuda90]  pytorch
pytz                      2018.5                     py_0    conda-forge
pyyaml                    3.12                     py36_1    conda-forge
pyzmq                     17.0.0                   py36_4    conda-forge
r-base                    3.4.1                         4    conda-forge
r-base64enc               0.1_3                  r3.4.1_0    conda-forge
r-crayon                  1.3.4                  r3.4.1_0    conda-forge
r-digest                  0.6.15                 r3.4.1_0    conda-forge
r-evaluate                0.10.1                 r3.4.1_0    conda-forge
r-glue                    1.2.0                  r3.4.1_0    conda-forge
r-htmltools               0.3.6                  r3.4.1_0    conda-forge
r-irdisplay               0.4.4                  r3.4.1_0    conda-forge
r-irkernel                0.8.12                   r341_0    conda-forge
r-jsonlite                1.5                    r3.4.1_0    conda-forge
r-magrittr                1.5                    r3.4.1_0    conda-forge
r-pbdzmq                  0.3_2                  r3.4.1_0    conda-forge
r-r6                      2.2.2                  r3.4.1_0    conda-forge
r-rcpp                    0.12.15                r3.4.1_0    conda-forge
r-repr                    0.15                     r341_0    conda-forge
r-stringi                 1.2.3                    r341_0    conda-forge
r-stringr                 1.3.1                    r341_0    conda-forge
r-uuid                    0.1_2                  r3.4.1_0    conda-forge
ray                       0.5.0                     <pip>
readline                  7.0                           0    conda-forge
redis                     2.10.6                    <pip>
requests                  2.19.1                   py36_0    conda-forge
requests-file             1.4.3                    py36_0    defaults
requests-ftp              0.3.1                    py36_0    conda-forge
rsa                       3.4.2                    py36_0    conda-forge
ruamel_yaml               0.15.42          py36h470a237_0    conda-forge
s3fs                      0.1.5                      py_0    conda-forge
s3transfer                0.1.13                   py36_0    conda-forge
scikit-learn              0.19.1          py36_blas_openblas_201  [blas_openblas]  conda-forge
scipy                     1.1.0           py36_blas_openblas_200  [blas_openblas]  conda-forge
seaborn                   0.8.1                    py36_0    conda-forge
send2trash                1.5.0                      py_0    conda-forge
service_identity          17.0.0                     py_0    conda-forge
setuptools                39.2.0                   py36_0    conda-forge
simplegeneric             0.8.1                      py_1    conda-forge
sip                       4.19.8                   py36_0    conda-forge
six                       1.11.0                   py36_1    conda-forge
snappy                    1.1.7                hfc679d8_2    conda-forge
sortedcontainers          2.0.4                    py36_0    conda-forge
sparkmonitor              0.0.9                     <pip>
sqlalchemy                1.2.9                    py36_0    conda-forge
sqlite                    3.20.1                        2    conda-forge
statsmodels               0.9.0                    py36_0    conda-forge
tblib                     1.3.2                    py36_0    conda-forge
tensorboard               1.8.0                    py36_1    conda-forge
tensorflow                1.8.0                    py36_1    conda-forge
tensorflow-gpu            1.8.0                     <pip>
tensorflow-hub            0.1.0                     <pip>
tensorflowonspark         1.3.0                     <pip>
termcolor                 1.1.0                      py_2    conda-forge
terminado                 0.8.1                    py36_0    conda-forge
testpath                  0.3.1                    py36_0    conda-forge
theano                    1.0.2                    py36_0    conda-forge
tk                        8.6.7                         0    conda-forge
toolz                     0.9.0                      py_0    conda-forge
torchvision               0.2.1                    py36_0    conda-forge
toree                     0.2.0                     <pip>
tornado                   5.0.2                    py36_0    conda-forge
tqdm                      4.23.4                     py_0    conda-forge
traitlets                 4.3.2                    py36_0    conda-forge
twisted                   17.5.0                   py36_0    defaults
typing                    3.6.4                    py36_0    conda-forge
urllib3                   1.23                     py36_0    conda-forge
wcwidth                   0.1.7                      py_1    conda-forge
webencodings              0.5                      py36_0    conda-forge
werkzeug                  0.14.1                     py_0    conda-forge
wheel                     0.31.1                   py36_0    conda-forge
widgetsnbextension        3.2.1                    py36_0    conda-forge
wrapt                     1.10.11                  py36_0    conda-forge
xgboost                   0.72             py36hfc679d8_1    conda-forge
xlrd                      1.1.0                      py_2    conda-forge
xorg-kbproto              1.0.7                h470a237_2    conda-forge
xorg-libice               1.0.9                h470a237_3    conda-forge
xorg-libsm                1.2.2                         2    conda-forge
xorg-libx11               1.6.5                         0    conda-forge
xorg-libxau               1.0.8                h470a237_5    conda-forge
xorg-libxdmcp             1.1.2                h470a237_6    conda-forge
xorg-libxrender           0.9.10                        0    conda-forge
xorg-renderproto          0.11.1               h470a237_2    conda-forge
xorg-xproto               7.0.31               h470a237_7    conda-forge
xz                        5.2.3                         0    conda-forge
yaml                      0.1.7                         0    conda-forge
yapf                      0.22.0                     py_0    conda-forge
zeromq                    4.2.5                hfc679d8_3    conda-forge
zict                      0.1.3                      py_0    conda-forge
zlib                      1.2.11               h470a237_3    conda-forge
zope.interface            4.5.0            py36h470a237_0    conda-forge
```