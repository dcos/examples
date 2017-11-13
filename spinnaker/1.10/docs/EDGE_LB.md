# Edge-LB with Spinnaker Server Groups

Edge-LB is the load balancer that comes with DC/OS Enterprise. See the DC/OS Enterprise documentation on how to install Edge-LB.

Create a *config.yaml* file with the following Edge-LB configuration. This configuration works with the [rolling blue green](PIPELINES.md#creating-a-rolling-blue-green-pipeline) sample.

```
---
pools:
  - name: myapp-prod-pool
    count: 1
    haproxy:
      frontends:
        - bindPort: 80
          protocol: HTTP
          linkBackend:
            defaultBackend: myapp-prod
      backends:
        - name: myapp-prod
          protocol: HTTP
          balance: roundrobin
          servers:
            - type: AGENT_IP
              framework:
                value: marathon
              task:
                value: "^myapp-prod-v[0-9]+\\.my-dcos-account$"
                match: REGEX
              port:
                name: web
```

The configuration is launched with the following command.

```
dcos edgelb config config.yaml
```

Edge-LB will roundrobin over the instances in the server groups of the *myapp-prod* cluster.

