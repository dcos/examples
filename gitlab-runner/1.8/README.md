# How to use GitLab Runner on DC/OS

[GitLab Runner](https://docs.gitlab.com/runner/) is the open source project that is used to run your jobs and send the results back to GitLab. It is used in conjunction with [GitLab CI](https://about.gitlab.com/gitlab-ci/), the open-source continuous integration service included with GitLab that coordinates the jobs.

- Estimated time for completion: 10 minutes
- Target audience: Anyone interested in using GitLab CI, and therefore need GitLab Runners.
- Scope: Learn how to install GitLab Runners on DC/OS

## Prerequisites

- A running DC/OS 1.8 cluster with at least 1 node having at least 1 CPU and 2 GB of RAM available.
- [DC/OS CLI](https://dcos.io/docs/1.8/usage/cli/install/) installed.
- A running GitLab instance, preferably installed from the Universe.

## Concepts

The GitLab Runner comes with a Docker-in-Docker daemon installed. This means that it can be used for build _within_ Docker containers, and at the same time adhere to the resource constraints set by Mesos. There's an [interesting comment](https://github.com/mesosphere/jenkins-dind-agent/issues/1#issuecomment-203126275) about the pros and cons of running CI jobs with DinD or a `docker.socket` mount.
 
This package supports two different GitLab Runner [executor types](https://docs.gitlab.com/runner/executors/#selecting-the-executor):

* `shell`: Can be used to build Docker images
* `docker`: Can be used to run builds _inside_ Docker containers

If you'd like to be able to do both, you'll need to start at least two instances of this Universe package, one with the `shell` executor, and one with the `docker` executor.

## Install GitLab Runners

To use the GitLab Runners, you have to at least specify the service name, know how, respectively under which service name, your GitLab CE/EE instance was started, and the registration token. The latter is needed to be able to connect the GitLab Runners to the GitLab instance, and is available on GitLab -> Admin -> Runners. 

The default resources for the GitLab Runners are `1.0` cpus and `2048` megabytes of memory. You can change this by setting the `service.cpus` and `service.mem` properties in the `options.json` files, as described below. When you don't specify the `service.instances` property, the package will only start one instance.

### Shell runner configuration

Let's get started by creating a file called `options.json` with following contents:

```json
{
  "service": {
    "name": "gitlab-runner-shell"
  },
  "gitlab": {
    "service-name": "gitlab.marathon.mesos",
    "registration-token": "abc123"
  },
  "gitlab-runner": {
    "executor": "shell",
    "tag-list": "build-as-docker,build-in-shell",
    "concurrent-builds": 4
  }
}
```

This assumes that your GitLab instance is running as service `gitlab`, and having the `gitlab.marathon.mesos` Mesos DNS hostname respectively. You need to replace the `abc123` registration token with the real one you looked up in the GitLab configuration before (see above).

Furthermore, the number of concurrent builds has been increased to four. You can now use this runner by specifying the `build-as-docker` tag in your project's `.gitlab-ci.yml` (see below).

### Docker runner configuration

Make sure you choose a useful default Docker image via `gitlab-runner.docker-default-image`, for example if you want to build Node.js projects, the `node:6-wheezy` image. This can be overwritten with the `image` property in the `.gitlab-ci.yml` file (see the [GitLab CI docs](https://docs.gitlab.com/ce/ci/yaml/README.html).

```json
{
  "service": {
    "name": "gitlab-runner-docker"
  },
  "gitlab": {
    "service-name": "gitlab.marathon.mesos",
    "registration-token": "abc123"
  },
  "gitlab-runner": {
    "executor": "docker",
    "tag-list": "build-in-docker,docker",
    "concurrent-builds": 4,
    "docker-default-image": "node:6-wheezy",
    "docker-insecure-registry": "myregistry.mydomain.mytld"
  }
}
```

In this example, we also configured a insecure Docker registry via the `gitlab-runner.docker-insecure-registry` property (this isn't mandatory, just as an example). If you want to use a private Docker registry with authentication, please have a look below on how to configure this as well.

### Launching a GitLab Runner

To install the package with the CLI, run the following:

```bash
$ dcos package install --options=options.json gitlab-runner
```

## Usage in GitLab CI

To get an overview on what you can do with CI settings, please refer to the [GitLab CI docs](https://docs.gitlab.com/ce/ci/yaml/README.html). Find some examples below for the usage with the different executor types of this package.

### Builds as Docker

An `.gitlab-ci.yml` example of using the `build-as-docker` tag to trigger a build on the runner(s) with shell executors:

```yaml
stages:
  - ci

build-job:
  stage: ci
  tags:
    - build-as-docker
  script:
    - docker build -t myuser/test .
```

This assumes your project has a `Dockerfile`, for example

```
FROM nginx
```

### Builds in Docker

An `.gitlab-ci.yml` example of using the `build-in-docker` tag to trigger a build on the runner(s) with Docker executors:

```yaml
image: node:6-wheezy

stages:
  - ci

test-job:
  stage: ci
  tags:
    - build-in-docker
  script:
    - node --version
```

## Additional info

### Using private Docker registries

If you want to use a private Docker registry (with authentication enabled), please follow the [instructions](https://docs.gitlab.com/runner/configuration/advanced-configuration.html#using-a-private-container-registry).

In the case you want to use an insecure registry, you can add the registry's `<hostname>:<port>` information to the `gitlab-runner.docker-insecure-registry` config property (when using an `options.json` via CLI), or during the advanced installation via UI. 

### Using (other/additional) environment variables for the runners
 
If you want to use environment variables to influence the GitLab Runner's configurations, please have a look at the [respective docs](https://github.com/ayufan/gitlab-ci-multi-runner/blob/master/docs/commands/README.md#using-environment-variables).
