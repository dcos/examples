---
post_title: Uninstall
menu_order: 30
enterprise: 'no'
---

<!-- THIS CONTENT DUPLICATES THE DC/OS OPERATION GUIDE -->

### DC/OS 1.10

If you are running TensorFlow on DC/OS 1.10:

1. Uninstall the service. From the DC/OS CLI, enter `dcos package uninstall --app-id=<instancename> tensorflow`.

For example, to uninstall a TensorFlow instance named `mnist`, run:

```shell
$ dcos package uninstall --app-id=/mnist tensorflow
```

### Older versions

If you are running TensorFlow DC/OS 1.9 or older, follow these steps:

1. Stop the service. From the DC/OS CLI, enter `dcos package uninstall --app-id=<instancename> tensorflow`.
   For example, `dcos package uninstall --app-id=mnist tensorflow`.
1. Clean up remaining reserved resources with the framework cleaner script, `janitor.py`. See [DC/OS documentation](https://docs.mesosphere.com/deploying-services/uninstall/#framework-cleaner) for more information about the framework cleaner script.

For example, to uninstall a Cassandra instance named `mnist`, run:

```shell
$ MY_SERVICE_NAME=mnist
$ dcos package uninstall --app-id=/$MY_SERVICE_NAME tensorflow
$ dcos node ssh --master-proxy --leader "docker run mesosphere/janitor /janitor.py \
    -r $MY_SERVICE_NAME-role \
    -p $MY_SERVICE_NAME-principal \
    -z dcos-service-$MY_SERVICE_NAME"
```

<!-- END DUPLICATE BLOCK -->
