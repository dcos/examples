---
post_title: API Reference
menu_order: 70
enterprise: 'no'
---

<!-- {% raw %} disable mustache templating in this file: retain nifid examples as-is -->

The DC/OS Apache Nifi Service implements a REST API that may be accessed from outside the cluster. The <dcos_url> parameter referenced below indicates the base URL of the DC/OS cluster on which the DC/OS Apache Nifi Service is deployed.

<a name="#rest-auth"></a>
# REST API Authentication
REST API requests must be authenticated. This authentication is only applicable for interacting with the DC/OS Apache Nifi REST API directly. You do not need the token to access the Apache Nifi nodes themselves.

If you are using Enterprise DC/OS, follow these instructions to [create a service account](../security/serviceaccountdetail.md) and an [authentication token](https://docs.mesosphere.com/1.10/security/ent/service-auth/custom-service-auth/). You can then configure your service to automatically refresh the authentication token when it expires. 

Once you have the authentication token, you can store it in an environment variable and reference it in your REST API calls:

```shell
export auth_token=uSeR_t0k3n
```

The `curl` examples in this document assume that an auth token has been stored in an environment variable named `auth_token`.

If you are using Enterprise DC/OS, the security mode of your installation may also require the `--ca-cert` flag when making REST calls. Refer to [Obtaining and passing the DC/OS certificate in Curl requests](https://docs.mesosphere.com/1.10/security/ent/tls-ssl/ca-trust-curl/) for information on how to use the `--cacert` flag. [If your security mode is `disabled`](https://docs.mesosphere.com/1.10/security/ent/secrets/seal-store/), do not use the `--ca-cert` flag.

# Plan API
The Plan API provides endpoints for monitoring and controlling service installation and configuration updates.


## List plans
You may list the configured plans for the service. By default, all services at least have a deploy plan and a recovery plan. Some services may have additional custom plans defined.

```shell
curl -H "Authorization:token=$auth_token" <dcos_url>/service/nifi/v1/plans
```

```shell
dcos nifi --name=nifi plan list
```

## View plan
You may view the current state of a listed plan:

```shell
curl -H "Authorization:token=$auth_token" <dcos_url>/service/nifi/v1/plans/<plan>
```

The CLI may be used to show a formatted tree of the plan (default), or the underlying JSON data as retrieved from the above HTTP endpoint:

```shell
dcos nifi --name=nifi plan show <plan>
```

```shell
dcos nifi --name=nifi plan show <plan> --json
```


## Pause plan

The installation will pause after completing installation of the current node and wait for user input before proceeding further.

```shell
curl -X POST -H "Authorization:token=$auth_token" <dcos_url>/service/nifi/v1/plans/deploy/interrupt
```

```shell
dcos nifi --name=nifi plan pause deploy
```

## Resume plan

The REST API request below will resume installation at the next pending node.

```shell
curl -X PUT <dcos_surl>/service/nifi/v1/plans/deploy/continue
```

```shell
dcos nifi --name=nifi plan continue deploy
```

# Connection API

```shell
curl -H "Authorization:token=$auth_token" dcos_url/service/nifi/v1/endpoints/<endpoint>
```

You will see a response similar to the following:

<!-- TODO: provide endpoint <endpoint> example (default options) output -->

The contents of the endpoint response contain details sufficient for clients to connect to the service.

# Nodes API

The pod API provides endpoints for retrieving information about nodes, restarting them, and replacing them.

## List Nodes

A list of available node ids can be retrieved by sending a GET request to `/v1/pod`:

CLI Example

```shell
dcos nifi pod list
```

HTTP Example

```shell
curl  -H "Authorization:token=$auth_token" <dcos_url>/service/nifi/v1/pod
```

You will see a response similar to the following:

<!-- TODO: provide pod list example (default options) output -->

## Node Info

You can retrieve node information by sending a GET request to `/v1/pod/<node-id>/info`:

```shell
curl  -H "Authorization:token=$auth_token" <dcos_url>/service/nifi/v1/pod/<node-id>/info
```

You will see a response similar to the following:

<!-- TODO: using node-0 here, but ensure that the node name matches a Apache Nifi service node type -->

CLI Example

```shell
dcos nifi pod info node-0
```

HTTP Example

```shell
curl  -H "Authorization:token=$auth_token" <dcos_url>/service/nifi/v1/pod/node-0/info
```

You will see a response similar to the following:

<!-- TODO: provide pod <node-id> example (default options) output -->

## Replace a Node

The replace endpoint can be used to replace a node with an instance running on another agent node.

CLI Example

```shell
dcos nifi pod replace <node-id>
```

HTTP Example

```shell
curl -X POST -H "Authorization:token=$auth_token" <dcos_url>/service/nifi/v1/pod/<node-id>/replace
```

If the operation succeeds, a `200 OK` is returned.

## Restart a Node

The restart endpoint can be used to restart a node in place on the same agent node.

CLI Example

```shell
dcos nifi pod restart <node-id>
```

HTTP Example

```shell
curl -X POST -H "Authorization:token=$auth_token" <dcos_url>/service/nifi/v1/pod/<node-id>/restart
```

If the operation succeeds a `200 OK` is returned.

## Pause a Node
The pause endpoint can be used to relaunch a node in an idle command state for debugging purposes.

CLI example

```shell
dcos nifi --name=nifi debug pod pause <node-id>
```

HTTP Example

```shell
curl -X POST -H "Authorization:token=$auth_token" <dcos_url>/service/nifi/v1/pod/<node-id>/pause
```


# Configuration API

The configuration API provides an endpoint to view current and previous configurations of the cluster.

## View Target Config

You can view the current target configuration by sending a GET request to `/v1/configurations/target`.

CLI Example

```shell
dcos nifi config target
```

HTTP Example

```shell
curl -H "Authorization:token=$auth_token" <dcos_url>/service/nifi/v1/configurations/target
```

You will see a response similar to the following:

<!-- TODO: provide configurations/target example (default options) output -->

## List Configs

You can list all configuration IDs by sending a GET request to `/v1/configurations`.

CLI Example

```shell
dcos nifi config list
```

HTTP Example

```shell
curl -H "Authorization:token=$auth_token" <dcos_url>/service/nifi/v1/configurations
```

You will see a response similar to the following:

<!-- TODO: provide configurations example (default options) output -->

## View Specified Config

You can view a specific configuration by sending a GET request to `/v1/configurations/<config-id>`.

CLI Example

```shell
dcos nifi config show 9a8d4308-ab9d-4121-b460-696ec3368ad6
```

HTTP Example

```shell
curl -H "Authorization:token=$auth_token" <dcos_url>/service/nifi/v1/configurations/9a8d4308-ab9d-4121-b460-696ec3368ad6
```

You will see a response similar to the target config above.

# Service Status Info
Send a GET request to the `/v1/state/properties/suppressed` endpoint to learn if DC/OS Apache Nifi is in a `suppressed` state and not receiving offers. If a service does not need offers, Mesos can "suppress" it so that other services are not starved for resources.
You can use this request to troubleshoot: if you think DC/OS Apache Nifi should be receiving resource offers, but is not, you can use this API call to see if DC/OS Apache Nifi is suppressed.

```shell
curl -H "Authorization: token=$auth_token" "<dcos_url>/service/nifi/v1/state/properties/suppressed"
```



# Apache Nifi Node Operations
These operations provide access to the Nifi cluster node using the available Nifi REST Api. The Rest Api provides programmatic access to command and control a NiFi instance in real time. You can see the [Nifi REST Api](https://nifi.apache.org/docs/nifi-docs/rest-api/index.html) for more about the available Api.


## List Nifi Cluster Summary

CLI Example
```shell
dcos nifi cluster summary
```

HTTP Example

```shell
curl -H "Authorization:token=$auth_token" <dcos_url>/service/nifi/v1/cluster/
```


## List Nifi Node

CLI Example
```shell
dcos nifi node list
```

HTTP Example

```shell
curl -H "Authorization:token=$auth_token" <dcos_url>/service/nifi/v1/nodes/
```

## List Nifi Node for a status

CLI Example
```shell
dcos nifi node status <nifi_node_status>
```

HTTP Example

```shell
curl -H "Authorization:token=$auth_token" <dcos_url>/service/nifi/v1/nodes/status/<nifi_node_status>
```

## Details of a Nifi Node

CLI Example
```shell
dcos nifi node <nifi_node_id>
```

HTTP Example

```shell
curl -H "Authorization:token=$auth_token" <dcos_url>/service/nifi/v1/nodes/<nifi_node_id>
```


## Remove a Nifi Node

CLI Example
```shell
dcos nifi node remove <nifi_node_id>
```

HTTP Example

```shell
curl -H "Authorization:token=$auth_token" <dcos_url>/service/nifi/v1/nodes/remove/<nifi_node_id>
```



## Control Nifi Node using GET endpoint
All Nifi [endpoints](https://nifi.apache.org/docs/nifi-docs/rest-api/index.html) uses GET method are accessable using below DC/OS cli and http.

CLI Example
```shell
dcos nifi api get <nifi_get_endpoints_uri>
```

HTTP Example

```shell
curl -H "Authorization:token=$auth_token" <dcos_url>/service/nifi/v1/nifi-api/get?uri=<nifi_get_endpoints_uri>
```

## Control Nifi Node using POST endpoint
All Nifi [endpoints](https://nifi.apache.org/docs/nifi-docs/rest-api/index.html) uses POST method are accessable using below DC/OS cli and http.

CLI Example
```shell
dcos nifi api post <nifi_post_endpoints_uri> stdin
{
  "id": "",
  "service": ""
}
```

OR

```shell
dcos nifi api post <nifi_post_endpoints_uri> <json_payload_file>
```



HTTP Example

```shell
curl -X POST -H "Authorization:token=$auth_token" <dcos_url>/service/nifi/v1/nifi-api/post?uri=<nifi_post_endpoints_uri>
{
  "id": "",
  "service": ""
}
```

## Control Nifi Node using PUT endpoint
All Nifi [endpoints](https://nifi.apache.org/docs/nifi-docs/rest-api/index.html) uses PUT method are accessable using below DC/OS cli and http.

CLI Example
```shell
dcos nifi api put <nifi_put_endpoints_uri> stdin
{
  "id": "",
  "service": ""
}
```

OR

```shell
dcos nifi api post <nifi_put_endpoints_uri> <json_payload_file>
```



HTTP Example

```shell
curl -X PUT -H "Authorization:token=$auth_token" <dcos_url>/service/nifi/v1/nifi-api/put?uri=<nifi_put_endpoints_uri>
{
  "id": "",
  "service": ""
}
```


## Control Nifi Node using DELETE endpoint
All Nifi [endpoints](https://nifi.apache.org/docs/nifi-docs/rest-api/index.html) uses DELETE method are accessable using below DC/OS cli and http.

CLI Example
```shell
dcos nifi api delete <nifi_delete_endpoints_uri>
```

HTTP Example

```shell
curl -X DELETE -H "Authorization:token=$auth_token" <dcos_url>/service/nifi/v1/nifi-api/delete?uri=<nifi_delete_endpoints_uri>
```
