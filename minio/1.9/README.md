# Install and use Minio on DC/OS

[Minio](https://minio.io) is an object storage server released under Apache License v2.0. It is compatible with Amazon S3 cloud storage service. It is best suited for storing unstructured data such as photos, videos, log files, backups and container / VM images. Size of an object can range from a few KBs to a maximum of 5TB.

Minio server is light enough to be bundled with the application stack, similar to NodeJS, Redis and MySQL. 

This installation uses the single node version of Minio (Minio FS), checkout the [Minio docs](https://docs.minio.io) for more details.

The instructions below use a pinned hostname constraint to ensure the application is always restarted on the same host by Marathon. This allows it to get back to its data but means that you could lose data if that agent goes down. 

- Estimated time for completion: less than 5 minutes. 
- Target audience:
    - Operators
    - Application admins
    - Developers 
    - Devops Engineers
- Scope: Learn to install Minio on DC/OS and learn to use it using Minio command line tool `mc`.

**Table of Contents**:

- [Prerequisites](#prerequisites)
- [Minio Installation using GUI](#minio-installation-using-gui)
- [Access Minio Browser](#access-minio-browser)
- [Install Minio Client](#install-minio-client)
- [Configure Minio Client](#configure-minio-client)
- [Uninstalling Minio](#uninstalling-minio)
- [Explore Further](#explore-further)

## Prerequisites

- DC/OS 1.9 or later
- [Marathon-LB](https://dcos.io/docs/1.9/usage/service-discovery/marathon-lb/usage/) must be installed and running
- Identify [IP of the public agent](https://dcos.io/docs/1.9/administration/locate-public-agent/) where Marathon-LB or an available hostname configured to point to the public agent(s) where Marathon-LB is running.

## Minio installation using GUI

- Visit the DC/OS admin page, and click on Universe on the left menu bar. Then click on the Packages tab and search for Minio, click on the ```Install``` button on the right hand side.

![Search & Install Minio](img/search-install.png)

- Then click on ```Advanced Installation```, enter configuration values like the storage and service type you’d like to use with your Minio instance. Finally specify the IP address or hostname of the public agent where Marathon-LB is running under ```networking >> public agent```. Make sure you remove the leading http:// and the trailing / from the IP.

![Public Agent](img/public-agent.png)

- We're ready to install! Click the green ```Review and Install``` button, verify your settings are correct and then click ```Install``` green button.

![Public Agent](img/verify-install.png)
 
- This completes the install process. Once Minio has been deployed, navigate to the IP/hostname you used earlier for Public Agent. You should see the following login page.

## Access Minio Browser

![Minio Browser](img/minio-browser.png)

- We need the access key and secret key from the Minio container logs. Click on ```Services``` Tab, select Minio service and select running instanct(```minio.852ac474-1de8-11e7-9209-ba9616e0f059```). Then go to the ```logs``` tab and copy the accesskey and secretkey.

![Minio Logs](img/minio-logs.png)

- Navigate to services UI and click on Minio and go to the logs section. Copy the _AccessKey_ and _SecretKey_ and use it to log into the browser console.

![Minio Browser](img/minio-access.png)

- Once you have successfully loggedin you should see the following screen. 

![Minio browser](img/minio-home.png)

## Install Minio Client

Minio Client (mc) provides a modern alternative to UNIX commands like ls, cat, cp, mirror, diff etc. It supports filesystems and Amazon S3 compatible cloud storage service (AWS Signature v2 and v4).

[Click here](https://docs.minio.io/docs/minio-client-quickstart-guide) for instructions on installing mc.

## Configure Minio Client

- There are different ways to configure Minio Client for different S3 cloud storage providers.
- Refer to [Guide](https://docs.minio.io/docs/minio-client-complete-guide) for further configuration.

### Example - Minio Cloud Storage

```sh
mc config host add <ALIAS> <YOUR-MINIO-BROWSER-ADDRESS> <YOUR-ACCESS-KEY> <YOUR-SECRET-KEY> <API-SIGNATURE>(optional)
```

*Example: Create a new bucket named "mybucket" on http://54.255.206.228*

```sh
mc config host add minio-dcos http://54.255.206.228 ELVUN4CWOAIRWOT2AO9D 4e6CIFtWW1/YI91Pd6FONRJgssKiFO2Ea1d5fDwp S3v4
mc mb minio-dcos/mybucket
Bucket created successfully ‘minio-dcos/mybucket’.
```
Now switch to Minio Browser, you can see mybacket in left-side panel where all the backets are listed.

Last but not least I want you to see what Minio’s resource footprint looks like:

![DCOS Dashboard](img/dcos-dashboard.png)

## Uninstalling Minio

```sh
dcos package uninstall minio
```

## Explore Further
- [Minio Erasure Code QuickStart Guide](https://docs.minio.io/docs/minio-erasure-code-quickstart-guide)
- [Use `mc` with Minio Server](https://docs.minio.io/docs/minio-client-quickstart-guide)
- [Minio Client SDK](https://docs.minio.io/categories/17)
- [Use `aws-cli` with Minio Server](https://docs.minio.io/docs/aws-cli-with-minio)
- [Use `s3cmd` with Minio Server](https://docs.minio.io/docs/s3cmd-with-minio)
- [Use `minio-go` SDK with Minio Server](https://docs.minio.io/docs/golang-client-quickstart-guide)
- [The Minio documentation website](https://docs.minio.io)
