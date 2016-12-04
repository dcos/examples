# How to use  Gitlab on DC/OS

[Gitlab](https://gitlab.com) an open source developer tool that allows you to host git repositories, review code, track issues, host Docker images and perform continuous integration.

Using GitLab on DC/OS now allows you to co-locate all of the tools you need for developers on one easy to manage cluster. Just as with any Universe package, you can robustly install several side by side instances of GitLab to provide segregated instances for each of your development teams. Alternatively, you can just as easily install GitLab in a highly available configuration that many teams use concurrently.

#IMAGE

This quickstart installation uses the single node version of GitLab that includes an installation of Postgres and Redis in the same container.

The instructions below use a pinned hostname constraint to success the application is always restarted on the same host by Marathon. This allows it to get back to its data but means that you could lose data if that agent goes down. We recommend checking out the production installation instructions on alternative options and considerations.

- Estimated time for completion: up to 10 minutes
- Target audience:
 - Operators
 - Application admins
 - Quality/Release engineers
 - CI/CD admins
- Scope: You'll learn how to install Gitlab and how to use it to build and deploy a Docker image on Marathon.

**Table of Contents**:

- [Prerequisites](#prerequisites)
- [Setting up Gitlab](#setting-up-gitlab)

## Prerequisites

- DC/OS 1.8 or later
- [Marathon-lb](https://dcos.io/docs/1.8/usage/service-discovery/marathon-lb/usage/) must be installed and running
- [Jenkins](https://docs.mesosphere.com/1.8/usage/service-guides/jenkins/) must be installed and running
- An available hostname configured to point to the public agent(s) where Marathon-lb is running (e.g. `gitlab-test.mesosphere.com`)
- Either set up appropriate certificates on each of your hosts, or configure each of your hosts to use your hostname (i.e. `gitlab-test.mesosphere.com`) as a [Docker insecure registry](https://docs.docker.com/registry/insecure/).
You will need to do this for the Jenkins agent too using the [Advanced Configuration instructions](https://docs.mesosphere.com/1.8/usage/service-guides/jenkins/advanced-configuration/).
- Ports 22222 and 50000 opened on the public agent where Marathon-lb is running. If you're using an ELB or similar in front of the public agent, make sure it's listening on those ports too.

## Setting up Gitlab

1. Before starting, identify the hostname of a private agent that you'd like to install GitLab to. Typically this will be one that has an EBS volume or similar mounted, that you are regularly snapshotting or have set up some other sort of backup solution on. You can pick one of these by visiting the "Nodes" page on your cluster and choosing a private node. We'll use `10.0.0.134` for this example.

#IMAGE

- Visit the Universe page in DC/OS, and click on the "Install Package" button underneath GitLab.
- Click on "Advanced Installation" and navigate to the "routing" tab. Specify the virtual host you prepared earlier, e.g. `gitlab-test.mesosphere.com`:

# IMAGE

- Finally, let's enter the hostname we want GitLab to run on. Navigate to the "single-node" tab and put the node hostname you picked earlier into the pinned hostname field:

# IMAGE

- We're ready to install! Click the green "Review and Install" button, verify your settings are correct and then click "Install". Navigate to the services UI to see GitLab deploying. The first run will take a few minutes while it initialises the built-in Postgres database.
- Once GitLab has deployed, navigate to the hostname you used earlier for virtual host. You should see the following page inviting you to set up the root password:

# IMAGE

- Finally, you will want to ensure your DC/OS agents are authenticated against this registry. You can either run `docker login` on each of these nodes or [see the instructions](https://mesosphere.github.io/marathon/docs/native-docker-private-registry.html) on how you might distribute your Docker credentials.
