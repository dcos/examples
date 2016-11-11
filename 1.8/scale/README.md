# How to use Scale on DC/OS

[Scale](https://ngageoint.github.io/scale/) enables on-demand, near real-time, automated processing of large datasets (satellite, medical, audio, video, ...) using a dynamic bank of algorithms. Algorithm execution is seamlessly distributed across thousands of CPU cores. Docker provides algorithm containerization. Apache Mesos enables optimum resource utilization.

- Estimated time for completion: 20 minutes
- Target audience: Anyone interested in processing file-based feeds of data.
- Scope: Learn how to install Scale on DC/OS and how to launch a Scale job. 

**Terminology**:

- **Job** ... A discrete unit of work defined with inputs, outputs, resource requirements and contained within a Docker image.
- **Recipe** ... A graph of Jobs related to one another. Recipes can have sibling and dependent Jobs allowing for complex processing chains.
- **Workspace** ... The definition of where files should be stored. Scale supports NFS and S3, as well as any sort of network file system through host volume exposure.
- **Strike** ... Scale job that monitors for arrival of new data in Workspace and begins a Recipe or Job based on a configured trigger rule.

**Table of Contents**:

- [Prerequisites](#prerequisites)
- [Install Scale](#install-scale)
- [Configure AWS Resources](#configure-aws-resources)
- [Process data in Scale](#process-data-in-scale)
- [Uninstall Scale](#uninstall-scale)

## Prerequisites

- A running DC/OS 1.8 cluster with at least 3 nodes with each 4 CPUs and 4 GB of RAM available.
- [Elasticsearch](https://github.com/dcos/examples/tree/master/1.8/elasticsearch) package running within the DCOS cluster.
- [DC/OS CLI](https://dcos.io/docs/1.8/usage/cli/install/) installed.
- [AWS CLI](http://docs.aws.amazon.com/cli/latest/userguide/installing.html) installed and configured with a user capable of S3, SNS, SQS and IAM resource provisioning.

## Install Scale

Assuming you have a DC/OS cluster up and running with Elasticsearch, the first step is to install Scale:

```
$ dcos package install scale
This DC/OS Service is currently EXPERIMENTAL. There may be bugs, incomplete features, incorrect documentation, or other discrepancies.

We recommend a minimum of three nodes with at least 4 CPU and 6GB of RAM available for the Scale services and running Scale jobs.

By default, Elasticsearch package *must* be running within your DCOS cluster. If you wish to use an externally hosted Elasticsearch cluster, specify one or more of the nodes in comma delimited format in the SCALE_ELASTICSEARCH_URLS variable. For quick-start purposes, Scale is bootstrapped with a Postgres database. This should *NEVER* be used for production purposes as it offers no underlying storage persistence. It can be replaced with an externally hosted Postgres by setting DB_HOST and associated settings appropriately.

If you are running DCOS 1.8 Enterprise Edition or higher, you will need to set the DCOS_OAUTH_TOKEN in the DCOS section of the Advanced Settings. This value can be found within the dcos.toml file under in the dcos_acs_token value on a system with an authenticated DCOS CLI.
Continue installing? [yes/no] yes
Installing Marathon app for package [scale] version [4.0.0-0.0.1]
The Scale DCOS Service has been successfully installed!

        Documentation: https://ngageoint.github.io/scale/
        Issues: https://github.com/ngageoint/scale/issues
```

_Note_: The Scale package will install all required components, save for external dependency on Elasticsearch. This default is _not_ recommended for a production deployment, but will get you up and running quickly to experiment with the Scale system. The primary recommendation is to use an externally managed Postgres database for Scale state persistence. This can be accomplished by specifying the database connection information during installation in the `db` section of the config.json. A user name with ownership to an existing database containing the PostGIS extension is the only requirement.

Now, we validate if Scale is running and healthy, in the cluster itself. For this, go to the DC/OS UI and you should see scale, scale-db and scale-logstash there under the `Services` tab. There will be two entries for Scale under the `Services` tab. The one that has the DC/OS icon beside it also has a link on hover. This link will take you to the Scale UI.

## Configure AWS Resources

The provided Scale example is specific to AWS Simple Storage Service (S3) processing and for brevity uses the AWS CLI to configure needed AWS resources. This does not require Scale to be running within AWS, merely that you provide Scale the credentials to access. NOTE: In a production AWS environment, IAM roles applied to instances would be preferred over use of Access Keys associated with IAM users.

Deploy S3 Bucket, SNS Topic and SQS Queue. A CloudFormation template is provided to get these resources quickly instantiated. The only parameter that must be specified is the BucketName. The below example command to launch the template uses shell syntax to generate a bucket name that is unique to satisfy the global uniqueness constraint. If you prefer a specific name, replace the ParameterValue with your chosen name.

```bash
$ aws cloudformation create-stack --stack-name scale-s3-demo --template-body https://raw.githubusercontent.com/dcos/examples/master/1.8/scale/scale-demo-cloudformation.json --parameters "ParameterKey=S3BucketName,ParameterValue=scale-bucket-`date +"%Y%m%d-%H%M%S"`"
```

Describe Stack Resources. Creation of the CloudFormation stack from above should be completed in only a couple minutes. The following command may be used to extract information needed to set the IAM policy so Scale can access the created resources. If the Stack status is not CREATE_COMPLETE wait a minute and run it again. The OutputValues associated with UploadsQueueUrl and BucketName from this command are what will be needed.

```bash
$ aws cloudformation describe-stacks --stack-name scale-s3-demo
```

Create IAM User and Access Key. The Access Key and Secret Key should be noted as they will be needed by Scale to authenticate against AWS for access to our provisioned resources. Feel free to change the user name value as needed.

```bash
$ aws iam create-user --user-name scale-test-user
$ aws iam create-access-key --user-name scale-test-user
```

Create IAM policy and apply to user. The provided policy template will handle the ARNs of resources created by the above template. The policy will only need to be updated to reflect the ARNs if the defaults have been updated.

```bash
$ aws iam put-user-policy --user-name scale-test-user --policy-document https://raw.githubusercontent.com/dcos/examples/master/1.8/scale/scale-demo-policy.json --policy-name scale-demo-policy
```

## Process data in Scale

Configure Scale for processing. The final step to process data in our S3 bucket is to configure Scale with a workspace, Strike, job type and recipe type. The provided script can be used to quickly bootstrap Scale with the configuration necessary to extract the first MiB of input files and save them in the output workspace.

```bash
$ curl -L https://raw.githubusercontent.com/dcos/examples/master/1.8/scale/scale-init.sh  -o scale-init.sh
$ export DCOS_TOKEN="DCOS token that can found within ~/.dcos/dcos.toml once DCOS CLI is authenticated against DCOS cluster."
$ export DCOS_ROOT_URL="The externally routable Admin URL. Also found in ~/.dcos/dcos.toml."
$ export REGION_NAME="AWS Region where SQS and S3 bucket reside."
$ export BUCKET_NAME="AWS S3 bucket name only. Full ARN should NOT be used."
$ export QUEUE_NAME="AWS SQS queue name only. Full ARN should NOT be used."
$ export ACCESS_KEY="Access Key for IAM user that will access S3 and SQS resources."
$ export SECRET_KEY="Secret Key for IAM user that will access S3 and SQS resources."
$ sh scale-init.sh
```

Test Scale ingest. Now that our configuration is complete we can verify that Scale is ready to process. We will drop a new file into our bucket using the AWS CLI. This file can be anything, but a text file over 1 MiB is best to demonstrate the jobs ability to extract only the first MiB. The following will do nicely:

```bash
$ base64 /dev/urandom | head -c 2000000 > sample-data-2mb.txt
$ aws s3 cp --acl public-read sample-data-2mb.txt s3://scale-bucket/
```

View processing results. In the Scale UI, navigate to Jobs. A Read Bytes job should have completed. Click on the job in the table and see the outputs in the detail view. You should be able to see that the file size is 1MiB. Feel free to download and inspect. Congratulations, you've processed your first file within Scale! For more advanced examples refer to the [Scale GitHub](https://github.com/ngageoint/scale) and [Docker Hub](https://hub.docker.com/r/geoint/scale) repositories, as well as the [documentation](http://ngageoint.github.io/scale/).


## Uninstall Scale

To uninstall Scale:

```bash
$ dcos package uninstall scale
```

This will only remove the Scale scheduler as there are the db, logstash and webserver components that are bootstrapped by the scheduler container. To fully remove all traces of scale the following commands should be run:

```bash
dcos marathon app remove scale-db
dcos marathon app remove scale-logstash
dcos marathon app remove scale-webserver
```

## Further resources

- [Scale Documentation](http://ngageoint.github.io/scale/)
- [Scale API Documentation](http://ngageoint.github.io/scale/docs/rest/index.html)
- [Scale Architecture](http://ngageoint.github.io/scale/docs/architecture/overview.html)
- [Scale Issues](https://github.com/ngageoint/scale/issues/)
- [Scale Chat on Gitter](https://gitter.im/ngageoint/scale)
