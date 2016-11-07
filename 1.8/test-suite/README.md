# DC/OS 1.8 Examples Test Suite

This is the DC/OS 1.8 examples test suite (ETS) to make sure all the examples here actually work as described.

## Prerequisites 

- A running DC/OS 1.8.x cluster with 5 private agent + 1 public agent nodes each with at least 2 CPUs and at least 7 GB RAM, recommended instance types on AWS is [m3.xlarge](https://aws.amazon.com/ec2/instance-types/) and on Azure [D2](https://azure.microsoft.com/en-us/pricing/details/virtual-machines/linux/).
- [DC/OS CLI](https://dcos.io/docs/1.8/usage/cli/install/) installed, version `0.4.14` or above.

In order to run the ETS, clone the repo and change to the `1.8/test-suite/` directory.