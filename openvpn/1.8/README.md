# How to use OpenVPN
[OpenVPN](https://github.com/dcos-labs/dcos-openvpn) provides a VPN endpoint to enable secure access to your DC/OS cluster using a compatible OpenVPN client.


## Prerequisites

- A running DC/OS 1.8 cluster

## Installation

1. From the DC/OS Dashboard > Universe > Packages > enter openvpn in the search box
1. Select Install Package > Advanced Installation and scroll down
1. Configure both the ovpn_username & ovpn_password, which are required for the REST interface auth and for the Zookeeper ACL credentials
1. Select Review and Install > Install
1. The service is installed and runs through its configuration. When complete, it'll be marked as Running and Healthy
1. See Troubleshooting for any issues, otherwise go to Usage

## Usage

The exact endpoints can be confirmed from **DC/OS Dashboard > Services > OpenVPN > <running task> > Details**

1. OpenVPN is presented on 1194/UDP and any OpenVPN client will default to this port
1. The REST management interface is available on 5000/TCP and will be accessed at https://<IP>:5000
1. /status /test /client are all valid REST endpoints. /status does not require authentication as it is used for health checks

### Add a User

1. Authenticate and POST to the REST endpoint, the new user's credentials will be output to the POST body
```
curl -k -u username:password -X POST -d "name=<name of the user to add>" https://<IP>:5000/client
```
2. Copy the entire ouput and save to a single file called dcos.ovpn and add to a suitable OpenVPN client
3. You may need to review and amend the target server IP in the credentials
4. Test connecting with the OpenVPN client. For troubleshooting, OpenVPN clients offer useful output for debugging
5. The new client credentials will be backed up to Zookeeper for persistence in case the task is killed, and will be copied back as required

### Revoke a User

1. Using the same client endpoint, append the name of the user you wish to revoke
```
curl -k -u username:password -X DELETE https://<IP>:5000/client/<name of the user to revoke>
```
2. The client is correctly revoked from OpenVPN and the assets are removed from the container and Zookeeper

### Remove persistent data

Recursively delete the dcos-vpn znode, authenticating using the same ovpn_username and ovpn_password credentials configured on install

zk-shell and zkCLI can both be used.  TODO: Examples.

## Troubleshooting

1. Review stdout and stderr from the task's logs under the DC/OS Dashboard > Service > openvpn > running task > logs
2. If the task is running on DC/OS, get a shell on the running container to investigate further:
```
docker ps
docker exec -it <Container ID> /bin/bash
```
/dcos/bin/runs.sh & /dcos/dcos_openvpn/web.py are the two main files to investigate.

The container can also be launched local onto a Docker daemon.

`run.sh reset` & `run.sh reset_container` are useful for testing, resetting both the Zookeeper znode & container and just the container respectively.

Modifying run.sh run_server as follows it useful for testing changes to the REST interface

```
function run_server {
  source /dcos/bin/envs.sh
  check_status
  setup
  #ovpn_run --daemon
  ovpn_run
  #/usr/bin/python -m dcos_openvpn.main
}
```


### Support and bug reports

This project is currently community supported, feedback and contributions are welcome.

- [DC/OS community Slack](chat.dcos.io)
- [Repository](https://github.com/dcos-labs/dcos-openvpn)
