---
post_title: Version 1.5-NiFi
menu_order: 10
post_excerpt: ""
enterprise: 'no'
---

# DC/OS Apache NiFi Security

TThe DC/OS Apache NiFi service supports NiFi’s native transport encryption, authentication, and authorization mechanisms. The service provides automation and orchestration to simplify the usage of these important features.

A good overview of these features can be found  [here](https://nifi.apache.org/docs/nifi-docs/html/administration-guide.html). 

## Transport Encryption and SSL Authentication
With transport encryption enabled, DC/OS Apache NiFi will automatically deploy all nodes with the correct configuration to encrypt communication via SSL. The nodes will communicate securely between themselves using SSL. SSL authentication requires that all NiFi Nodes present a valid certificate from which their identity can be derived for communicating between themselves.
DC/OS Apache NiFi uses the CN of the SSL certificate as the principal for a given Node. 
For e.g. CN=nifi-0-node.demonifi, O="Mesosphere, Inc", L=San Francisco, ST=CA, C=US.

The service uses the [DC/OS CA](https://docs.mesosphere.com/latest/security/ent/tls-ssl/) to generate the SSL artifacts that it uses to secure the service. Any client that trusts the DC/OS CA will consider the service’s certificates valid.

Note: Enabling transport encryption is required to use [SSL authentication](https://docs.mesosphere.com/1.10/security/ent/tls-ssl/) for authentication, but is optional for Kerberos authentication.

## Prerequisites
- [A DC/OS Service Account with a secret stored in the DC/OS Secret Store.](https://docs.mesosphere.com/latest/security/ent/service-auth/custom-service-auth/)
- DC/OS Superuser permissions for modifying the permissions of the Service Account.

## Configure Transport Encryption

**Tip:** A complete guide to Configuring DC/OS Access for Nifi can be found [here](serviceaccountdetail.md).


## Setup the Service Account

Grant the service account the correct permissions.

In DC/OS 1.10, the required permission is dcos:superuser full
   
   ```shell
   curl -k -v $(dcos config show core.dcos_url)/ca/dcos-ca.crt -o ../dcos-ca.crt
   export LC_ALL=C.UTF-8
   export LANG=C.UTF-8
   dcos package install dcos-enterprise-cli
   dcos security org service-accounts keypair nifi-private-key.pem nifi-public-key.pem
   dcos security org service-accounts create -p nifi-public-key.pem -d "dcos_nifi" <service name>
   dcos security secrets create-sa-secret --strict nifi-private-key.pem <service name> <service name secret>
   dcos security org users grant <service name> dcos:superuser full --description "grant permission to superuser" 
   ```
where <service name> is the name of the service to be installed.

## Install the service

Install the DC/OS Apache NiFi service including the following options in addition to your own:

   ```shell
   {
    "service": {
       "service_account": "<your service account name>",
       "service_account_secret": "<full path of service secret>",
       "security": {
          "tls_ssl": {
             "enabled": true
                     }
                   }
               }
   }
   ```
    


## Transport Encryption for Clients

With Transport Encryption enabled, service clients will need to be configured to use [the DC/OS CA bundle](https://docs.mesosphere.com/latest/security/ent/tls-ssl/get-cert/) to verify the connections they make to the service. Consult your client’s documentation for trusting a CA and configure your client appropriately.

## Authentication

DC/OS Apache NiFi supports two authentication mechanisms, SSL and Kerberos. The two are supported independently and may not be combined. If both SSL and Kerberos authentication are enabled, the service will use Kerberos authentication.

Note: Kerberos authentication can, however, be combined with transport encryption.

## CA based authentication between nodes

DC/OS Apache NiFi requires certificated based authentication between nodes. 
DC/OS Apache NiFi uses the CN of the SSL certificate as the principal for a given Node. 
For e.g. CN=nifi-0-node.demonifi, O="Mesosphere, Inc", L=San Francisco, ST=CA, C=US.

## Kerberos Authentication for End Users

Kerberos authentication relies on a central authority to verify that NiFi Users clients are who they say they are. DC/OS Apache NiFi integrates with your existing Kerberos infrastructure to verify the identity of clients.

### Prerequisites
- The hostname and port of a KDC reachable from your DC/OS cluster
- Sufficient access to the KDC to create Kerberos principals
- Sufficient access to the KDC to retrieve a keytab for the generated principals
- [The DC/OS Enterprise CLI](https://docs.mesosphere.com/1.10/cli/enterprise-cli/#installing-the-dcos-enterprise-cli)
- DC/OS Superuser permissions

## Configure Kerberos Authentication
### Create principals

The DC/OS Apache NiFi service requires a Kerberos principal for the service principal and user principal.Each principal must be of the form

   ```shell
   nifinode@<service realm>
   nifiadmin@<service realm>
   ```
### Place Service Keytab in DC/OS Secret Store

The DC/OS Apache NiFi service uses a keytab containing above service and user principals (service keytab). After creating the principals above, generate the service keytab making sure to include all the node principals. This will be stored as a secret in the DC/OS Secret Store by name __dcos_base64__secret_name .The DC/OS security modules will handle decoding the file when it is used by the service. More details [here.](https://docs.mesosphere.com/services/ops-guide/overview/#binary-secrets)

Documentation for adding a file to the secret store can be found [here.](https://docs.mesosphere.com/latest/security/ent/secrets/create-secrets/#creating-secrets-from-a-file-via-the-dcos-enterprise-cli)

Note: Secrets access is controlled by [DC/OS Spaces](https://docs.mesosphere.com/latest/security/ent/#spaces-for-secrets), which function like namespaces. Any secret in the same DC/OS Space as the service will be accessible by the service. 

### Install the Service
Install the DC/OS Apache NiFi service with the following options in addition to your own:
   ```shell
   {
    "service": {
        "security": {
            "kerberos": {
                "enabled": true,
                "kdc": {
                    "hostname": "<kdc host>",
                    "port": <kdc port>
                },
                "primary": "<service primary default nifi>",
                "realm": "<realm>",
                "keytab_secret": "<path to keytab secret>",
                "service_principal": "nifinode@<service realm>",
                "user_principal": "nifiadmin@<service realm>"
            }
        }
    }
}
   ```

