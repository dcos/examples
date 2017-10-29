# Running TensorFlow on DC/OS

**NOTE:** The DC/OS TensorFlow package referenced in this example is a community package.

[TensorFlow](https://www.tensorflow.org/) is an open-source software library for machine intelligence which is extremely powerful especially in a distributed setting. This example aims to demonstrate the use of the DC/OS TensorFlow package to train a simple TensorFlow model for solving the [MNIST](https://www.tensorflow.org/get_started/mnist/beginners) handwriting recognition problem.

- Estimated time for completion: 10 minutes
- Target audience: Anyone who wants to deploy a distributed TensorFlow on DC/OS. Beginner level.
- Scope: Covers the basics in order to get you started with TensorFlow on DC/OS.

## Prerequisites

- A running DC/OS 1.10 cluster with at least 3 nodes having 6CPU, 12GB of memory in total. This exact amount depends on your configuration for the gpuworker, worker, and parameter_server tasks.
- [DC/OS CLI](https://dcos.io/docs/1.10/usage/cli/install/) installed.
- If you want to benefit from GPU acceleration, please check how to [install DC/OS on GPU instances](https://dcos.io/docs/1.10/deploying-services/gpu/#installing-dc-os-with-gpus-enabled)

## Let's get started!

### Clone the DC/OS TensorFlow tools repository

This guide is based on one of the examples from the [DC/OS TensorFlow tools repository](https://github.com/dcos-labs/dcos-tensorflow-tools), and as such this should be cloned:
```shell
$ git clone git@github.com:dcos-labs/dcos-tensorflow-tools.git
$ cd dcos-tensorflow-tools
```
Checking the contents of this directory, at least the `examples/mnist.json` should be present:
```shell
$ ls -ll examples/mnist.json
-rw-r--r--  1 elezar  staff  968 Oct 27 16:18 examples/mnist.json
```

### Ensure that the DC/OS TensorFlow package is avalaible

This can be done by checking the Catalog in the DC/OS UI to see whether the `beta-tensorflow` package can be found or using the CLI using the `dcos package search command`:
```shell
$ dcos package search tensorflow
NAME             VERSION           SELECTED  FRAMEWORK  DESCRIPTION
beta-tensorflow  0.1.0-1.3.0-beta  False     True       TensorFlow on DC/OS
```
This indicates that `beta-tensorflow` with a package version of `0.1.0-1.3.0-beta` is available.

When running:
```shell
$ dcos package describe beta-tensorflow
```
The configurable options in the DC/OS TensorFlow package and their defaults are presented.

### Get to know the MNIST example

One of the examples in the DC/OS TensorFlow tools repository is [MNIST](https://www.tensorflow.org/get_started/mnist/beginners) which is used as a basic example in many machine learning applications.

When looking at the contents of the `examples/mnist.json` file that was cloned as part of the `dcos-tensorflow-tools` repo, a number of sections are noted. The ones of interest for the purpose of this introduction are `service` and `worker`.

#### Job definition

The `service` section defines the properties of the job to be executed. Most importantly, `job_url` defines the location (URI) of an archive containing the job definition. Additional `job_*` properties are related to the structure of the archive defined in `job_url` as well as settings specific to the job:
```json
    "job_url": "https://downloads.mesosphere.com/tensorflow-dcos/examples/tf_examples-master.zip",
    "job_path": "tf_examples-master",
    "job_name": "demo",
    "job_context": "{\"learning_rate\":0.5,\"num_training_steps\":1000000}",
```
also note that the service `name` is specified as `"mnist"`.

In order to better understand this, we can download and extract the `job_url` archive and check the contents:
```shell
$ wget -q https://downloads.mesosphere.com/tensorflow-dcos/examples/tf_examples-master.zip
$ unzip tf_examples-master.zip
$ ls tf_examples-master/
README.md  benchmarks demo.py
```

The other configuration options can then be interpreted as follows:
* `job_path`: The path (relative to the current directory) where the job definition can be found
* `job_name`: The base filename of the Python file where the job is defined

In the case of `examples/mnist.json`, this means that the file `tf_examples-master/demo.py` from the defined archive is used as the Python definition of the job.

The final setting, `job_context`, is used to pass parameters (e.g. learning rate or the number of training steps) to the job when it is executed.

#### Worker definition

In the `examples/mnist.json` file, the `worker` section defines the computational resources to be used to run the job as specified in the `service` section. In this case, we allocate 1 worker with 1 CPU, 1024 MB of memory and 1024 MB of disk space.

### Run the MNIST example

In order to run an example, we install the `beta-tensorflow` package specifying the JSON file as the `--options` argument:
```shell
$ dcos package install beta-tensorflow --yes --options=examples/mnist.json
By Deploying, you agree to the Terms and Conditions https://mesosphere.com/catalog-terms-conditions/#community-services
This is a community package. Community packages are unverified and unreviewed content from the community.
Installing Marathon app for package [beta-tensorflow] version [0.1.0-1.3.0-beta]
Installing CLI subcommand for package [beta-tensorflow] version [0.1.0-1.3.0-beta]
New command available: dcos beta-tensorflow
The DC/OS TensorFlow service is being installed!

	Documentation: https://mesosphere.github.io/dcos-tensorflow/
	Issues: https://chat.dcos.io
```
(Note that the `--yes` option just prevents a confirmation of the install process)

We can check the running tasks using:
```shell
$ dcos task
NAME           HOST        USER  STATE  ID                                                   MESOS ID
mnist          10.0.3.40   root    R    mnist.7efe24d5-bb28-11e7-88f6-2e6579fe0e78           519116bc-05ba-4039-8389-c007088cd573-S0
worker-0-node  10.0.1.119  root    R    worker-0-node__7502e7c6-f6d1-4eff-b2e0-724acbfbe37a  519116bc-05ba-4039-8389-c007088cd573-S2
```
and check the tail of the standard output of the above `worker-0` task using (you need to adapt the ID to your specific task):
```shell
$ dcos task log worker-0-node__7502e7c6-f6d1-4eff-b2e0-724acbfbe37a --all
Accuracy at global step 61620 (local step 61620): 0.923399984837
Accuracy at global step 61630 (local step 61630): 0.922500014305
Accuracy at global step 61640 (local step 61640): 0.921800017357
Accuracy at global step 61650 (local step 61650): 0.923500001431
Accuracy at global step 61660 (local step 61660): 0.923300027847
Accuracy at global step 61670 (local step 61670): 0.923500001431
Accuracy at global step 61680 (local step 61680): 0.923799991608
Accuracy at global step 61690 (local step 61690): 0.924199998379
Accuracy at global step 61700 (local step 61700): 0.923099994659
Accuracy at global step 61710 (local step 61710): 0.921299993992
```
(The `--all` ensures that we see the output for tasks that have completed due to reaching the specified number of global training steps)

### Cleaning up

Once the training is complete (or if we want to abort it), it is required that we uninstall the package:
```shell
$ dcos package uninstall beta-tensorflow --app-id=mnist --yes
Uninstalled package [beta-tensorflow] version [0.1.0-1.3.0-beta]
The DC/OS TensorFlow service is being uninstalled.

For DC/OS versions from 1.10 no further action is required. For older DC/OS versions follow the instructions at https://mesosphere.github.io/dcos-tensorflow/uninstall to remove any persistent state if required.
```


## Support and bug reports

The DC/OS TensorFlow package is currently community supported. If you get
stuck, need help or have questions, just ask via one of the following channels:

- [Slack](http://chat.dcos.com)
- [Google Group](https://groups.google.com/forum/#!forum/dcos-tensorflow)

## TODO:

This example (or extensions) could benefit from:

* How do I change configuration properties?
* How do I access my trained model files?
* When do I need parameter servers?
* How do I use TensorBoard?
* How does all of this work through the UI?
