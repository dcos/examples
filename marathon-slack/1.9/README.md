# How to use marathon-slack on DC/OS

[marathon-slack](https://github.com/tobilg/marathon-slack) is a tool for listening to the Marathon Event Bus, and forwarding selected events to a Slack incoming WebHook.

- Estimated time for completion: 15 minutes
- Target audience: Anyone interested in using marathon-slack to forward Marathon events to Slack
- Scope: Learn how to install marathon-slack

## Prerequisites

- A running DC/OS >= 1.8 cluster with at least 1 node having at least 0.1 CPUs and 128 MB of RAM available.
- [DC/OS CLI](https://dcos.io/docs/1.9/usage/cli/install/) installed.

## Install marathon-slack

`marathon-slack` can either be installed directly via Marathon application definition, or via Universe package.

Useful configuration parameters include the [event types](https://github.com/tobilg/marathon-slack#event-types) that should be forwarded, and regular expressions for filtering the application ids. (see the [docs](https://github.com/tobilg/marathon-slack#environment-variables)).

### Via Marathon application definition

Please replace the value for `<YOUR_WEBHOOK_URL>` with the real value. 

```javascript
{
  "id": "/marathon-slack",
  "cpus": 0.1,
  "mem": 128,
  "disk": 0,
  "instances": 1,
  "container": {
    "type": "DOCKER",
    "docker": {
      "image": "tobilg/marathon-slack:0.4.0",
      "network": "HOST",
      "forcePullImage": true
    }
  },
  "env": {
    "SLACK_WEBHOOK_URL": "<YOUR_WEBHOOK_URL>"
  },
  "labels":{
    "MARATHON_SINGLE_INSTANCE_APP": "true"
  },
  "upgradeStrategy":{
    "minimumHealthCapacity": 0,
    "maximumOverCapacity": 0
  },
  "portDefinitions": [
    {
      "port": 0,
      "protocol": "tcp",
      "name": "api"
    }
  ],
  "requirePorts": false,
  "healthChecks": [
    {
      "protocol": "HTTP",
      "portIndex": 0,
      "path": "/health",
      "gracePeriodSeconds": 5,
      "intervalSeconds": 20,
      "maxConsecutiveFailures": 3
    }
  ]
}
```

### Via Universe package

You can prepare a `marathon-slack.json` file with the installation options. Please replace the values in `<YOUR_WEBHOOK_URL>` with the real value for your incoming Slack WebHook.

```javascript
{
  "marathon-slack": {
    "slack_webhook_url": "https://hooks.slack.com/services/<YOUR_WEBHOOK_URL>"
  }
}
```

Run the installation with the dcos CLI like this:

```bash
$ dcos package install marathon-slack --options=marathon-slack.json
```

## Usage

`marathon-slack` will now forward you all defined event types to your defined Slack channel.
