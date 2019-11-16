# Configuring Jupyterlab Notebook for access through Edge-LB

## Tested against

- Jupyterlab Catalog 1.2.0-0.33.7
- EdgeLB 1.5
- DC/OS EE 1.13.4


## Requirments

- jupyterlab
- EdgeLB [![Generic badge](https://img.shields.io/badge/Enterprise-blueviolet.svg)]
- DC/OS EE
- a routable url for jupyter lab to a node eith edgelb pool

## Basics

jupyterlab was designed for use with Marahton-LB and still works. DC/OS Enterpise offers a differernt Edge Router called EdgeLB. EdgeLB allows different options that Marathon-LB and as such requires a different approach to exposing through a load balancer.

'''
    {
        "apiVersion": "V2",
        "name": "jupyterlab-routing",
        "count": 1,
        "autoCertificate": true,
        "haproxy": {
            "frontends": [
            {
                "bindPort": 80,
                "protocol": "HTTP",
                "redirectToHttps": {
                "host": [ "jupiter.dcos.example.com"]
                
                }
            },
            {
                "bindPort": 443,
                "protocol": "HTTPS",
                "certificates": [
                "$AUTOCERT"
                ],
                "linkBackend": {
                "map": [
                    {
                    "hostEq": "jupiter.dcos.codadensys.com",
                    "backend": "app-jupyter-with-path",
                    "pathReg":"jupyterlab-notebook"
                    },
                    {
                    "hostEq": "jupiter.dcos.codadensys.com",
                    "backend": "app-jupyter"
                    }
                ]
                }
            }
            ],
            "backends": [
            {
                "name": "app-jupyter",
                "protocol": "HTTP",
                "rewriteHttp": {
                "host":"jupiter.dcos.example.com",
                "path": {
                    "fromPath": "",
                    "toPath": "/jupyterlab-notebook"
                }
                },
                "services": [
                {
                    "marathon": {
                    "serviceID": "/jupyterlab-notebook"
                    },
                    "endpoint": {
                    "portName": "notebook"
                    }
                }
                ]
            },
            {
                "name": "app-jupyter-with-path",
                "protocol": "HTTP",
                "services": [
                {
                    "marathon": {
                    "serviceID": "/jupyterlab-notebook"
                    },
                    "endpoint": {
                    "portName": "notebook"
                    }
                }
                ]
            }
            ]
        }
    }
'''

This config will redirect  HTTP calls immediately to HTTPS, and then will handle the path manipulation of adding /jupyterlab-notebook when needed.

## Warning

As this config binds to port 80 and 443 on a edge node, if other services are routing using those ports, configs will need merged.
