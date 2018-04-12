---
post_title: Version 1.5-NiFi
menu_order: 10
post_excerpt: ""
enterprise: 'no'
---

# Components

The following components work together to deploy and maintain the service.

- Mesos

    Mesos is the foundation of the DC/OS cluster. Everything launched within the cluster is allocated resources and managed by Mesos. A typical Mesos cluster has one or three Masters that manage resources for the entire cluster. On DC/OS, the machines running the Mesos Masters will typically run other cluster services as well, such as Marathon and Cosmos, as local system processes. Separately from the Master machines are the Agent machines, which are where in-cluster processes are run. For more information on Mesos architecture, see the [Apache Mesos documentation](https://mesos.apache.org/documentation/latest/architecture/). For more information on DC/OS architecture, see the [DC/OS architecture documentation](https://docs.mesosphere.com/latest/overview/architecture/).

- ZooKeeper

    ZooKeeper is a common foundation for DC/OS system components, like Marathon and Mesos. It provides distributed key-value storage for configuration, synchronization, name registration, and cluster state storage. DC/OS comes with ZooKeeper installed by default, typically with one instance per DC/OS master.

    SDK Schedulers use the default ZooKeeper instance to store persistent state across restarts (under znodes named dcos-service-<svcname>). This allows Schedulers to be killed at any time and continue where they left off.

    **Note**: SDK Schedulers currently require ZooKeeper, but any persistent configuration storage (such as etcd) could fit this role. ZooKeeper is a convenient default because it is always present in DC/OS cluster

- Marathon

    Marathon is the “init system” of a DC/OS cluster. Marathon launches tasks in the cluster and keeps them running. From the perspective of Mesos, Marathon is itself another Scheduler running its own tasks. Marathon is more general than SDK Schedulers and mainly focuses on tasks that don’t require managing local persistent state. SDK services rely on Marathon to run the Scheduler and to provide it with a configuration via environment variables. The Scheduler, however, maintains its own service tasks without any direct involvement by Marathon.

- Scheduler

    The Scheduler is the “management layer” of the service. It launches the service nodes and keeps them running. It also exposes endpoints to allow end users to control the service and diagnose problems. The Scheduler is kept online by the cluster’s “init system”, Marathon. The Scheduler itself is effectively a Java application that is configured via environment variables provided by Marathon.

- Packaging

    Apache Nifi is packaged for deployment on DC/OS. DC/OS packages follow the [Universe schema](https://github.com/mesosphere/universe), which defines how packages expose customization options at initial installation. When a package is installed on the cluster, the packaging service (named ‘Cosmos’) creates a Marathon app that contains a rendered version of the marathon.json.mustache template provided by the package. For DC/OS Apache Nifi, this Marathon app is the scheduler for the service

    For further discussion of DC/OS components, see the [architecture documentation](https://docs.mesosphere.com/latest/overview/architecture/components/).

# Deployment

Internally, Nifi treats “Deployment” as moving from one state to another state. By this definition, “Deployment” applies to many scenarios:

    - When Nifi is first installed, deployment is moving from a null configuration to a deployed configuration.
    - When the deployed configuration is changed by editing an environment variable in the scheduler, deployment is moving from an initial running configuration to a new proposed configuration.

In this section, we’ll describe how these scenarios are handled by the scheduler.

## Initial Install

This is the flow for deploying a new service:

### Steps handled by the DC/OS cluster

    1. The user runs dcos package install Nifi in the DC/OS CLI or clicks Install for a given package on the DC/OS Dashboard.

    2. A request is sent to the Cosmos packaging service to deploy the requested package along with a set of configuration options.

    3. Cosmos creates a Marathon app definition by rendering Nifi’s marathon.json.mustache with the configuration options provided in the request, which represents Nifi’s Scheduler. Cosmos queries Marathon to create the app.

    4. Marathon launches the Nifi’s scheduler somewhere in the cluster using the rendered app definition provided by Cosmos.

    5. Nifi’s scheduler is launched. From this point onwards, the SDK handles deployment.

### Steps handled by the Scheduler

The scheduler starts with the following state:

    - A svc.yml template that represents the service configuration.
    
    - Environment variables provided by Marathon, to be applied onto the svc.yml template.
    
    - Any custom logic implemented by the service developer in their Main function (we’ll be assuming this is left with defaults for the purposes of this explanation).

  1. The svc.yml template is rendered using the environment variables provided by Marathon.

  2. The rendered svc.yml “Service Spec” contains the host/port for the ZooKeeper instance, which the Scheduler uses for persistent configuration/state storage. The default is master.mesos:2181, but may be manually configured to use a different ZooKeeper instance. The Scheduler always stores its information under a znode named dcos-service-<svcname>.

  3. The Scheduler connects to that ZooKeeper instance and checks to see if it has previously stored a Mesos Framework ID for itself.

        - If the Framework ID is present, the Scheduler will attempt to reconnect to Mesos using that ID. This may result in a “Framework has been removed” error if Mesos doesn’t recognize that Framework ID, indicating an incomplete uninstall.
        - If the Framework ID is not present, the Scheduler will attempt to register with Mesos as a Framework. Assuming this is successful, the resulting Framework ID is then immediately stored.

  4. Now that the Scheduler has registered as a Mesos Framework, it is able to start interacting with Mesos and receiving offers. When this begins, the scheduler will begin running the Offer Cycle and deploying nifi. See that section for more information.

  5. The Scheduler retrieves its deployed task state from ZooKeeper and finds that there are tasks that should be launched. This is the first launch, so all tasks need to be launched.

  6. The Scheduler deploys those missing tasks through the Mesos offer cycle using a Deployment Plan to determine the ordering of that deployment.

  7. Once the Scheduler has launched the missing tasks, its current configuration should match the desired configuration defined by the “Service Spec” extracted from svc.yml.
        a. When the current configuration matches the desired configuration, the Scheduler will tell Mesos to suspend sending new offers, as there’s nothing to be done.
        b. The Scheduler idles until it receives an RPC from Mesos notifying it of a task status change, it receives an RPC from an end user against one of its HTTP APIs, or until it is killed by Marathon as the result of a configuration change.


## Reconfiguration

This is the flow for reconfiguring a DC/OS service either in order to update specific configuration values, or to upgrade it to a new package version.

### Steps handled by the Scheduler

As with initial install above, at this point the Scheduler is re-launched with the same three sources of information it had before:

    - svc.yml template.
    - New environment variables.
    - Custom logic implemented by the service developer (if any).

In addition, the Scheduler now has a fourth piece:

    - Pre existing state in ZooKeeper

Scheduler reconfiguration is slightly different from initial deployment because the Scheduler is now comparing its current state to a non-empty prior state and determining what needs to be changed.

  1. After the Scheduler has rendered its svc.yml against the new environment variables, it has two Service Specs, reflecting two different configurations.
  
        - The Service Spec that was just rendered, reflecting the configuration change.
        - The prior Service Spec (or “Target Configuration”) that was previously stored in ZooKeeper.
    
  2. The Scheduler automatically compares the changes between the old and new Service Specs.
  
            a. Change validation: Certain changes, such as editing volumes and scale-down, are not currently supported because they are complicated and dangerous to get wrong.
                - If an invalid change is detected, the Scheduler will send an error message and refuse to proceed until the user has reverted the change by relaunching the Scheduler app in Marathon with the prior config.
                - If the changes are valid, the new configuration is stored in ZooKeeper as the new Target Configuration and the change deployment proceeds as described below.
                
            b. Change deployment: The Scheduler produces a diff between the current state and some future state, including all of the Mesos calls (reserve, unreserve, launch, destroy, etc.) needed to get there. For example, if the number of tasks has been increased, then the Scheduler will launch the correct number of new tasks. If a task configuration setting has been changed, the Scheduler will deploy that change to the relevant affected tasks by relaunching them. Tasks that aren’t affected by the configuration change will be left as-is.
            
            c. Custom update logic: Some services may have defined a custom update Plan in its svc.yml, in cases where different logic is needed for an update/upgrade than is needed for the initial deployment. When a custom update plan is defined, the Scheduler will automatically use this Plan, instead of the default deploy Plan, when rolling out an update to the service.


## Uninstallation

This is the flow for uninstalling nifi.

### Steps handled by the Cluster

1. The user uses the DC/OS CLI’s dcos package uninstall command to uninstall the service.
2. The DC/OS package manager instructs Marathon to kill the current Scheduler and to launch a new Scheduler with the environment variable SDK_UNINSTALL set to “true”.

### Steps handled by the Scheduler

When started in uninstall mode, the Scheduler performs the following actions:

    - Any Mesos resource reservations are unreserved.
        - Warning: Any data stored in reserved disk resources will be irretrievably lost.
    - Preexisting state in ZooKeeper is deleted.
    
# Pods

A Task generally maps to a single process within the service. A Pod is a collection of colocated Tasks that share an environment. All Tasks in a Pod will come up and go down together. Therefore, most maintenance operations against the service are at Pod granularity rather than Task granularity.
    
# Plans

The Scheduler organizes its work into a list of Plans. Every SDK Scheduler has at least a Deployment Plan and a Recovery Plan, but other Plans may also be added for things like custom Backup operations. The Deployment Plan is in charge of performing an initial deployment of the service. It is also used for rolling out configuration changes to the service (or in more abstract terms, handling the transition needed to get the service from some state to another state), unless the service developer provided a custom update Plan. The Recovery Plan is in charge of relaunching any exited tasks that should always be running.

Plans have a fixed three-level hierarchy. Plans contain Phases, and Phases contain Steps.

For example, let’s imagine a service with two index nodes and three data nodes. The Plan structure for a Scheduler in this configuration could look like this:

    Deployment Plan (deploy)
        Index Node Phase
            Index Node 0 Step
            Index Node 1 Step
        Data Node Phase
            Data Node 0 Step
            Data Node 1 Step
            Data Node 2 Step
    Custom Update Plan (update)
        (custom logic, if any, for rolling out a config update or software upgrade)
    Recovery Plan (recovery)
        (phases and steps are autogenerated as failures occur)
    Index Backup Plan
        Run Reindex Phase
            Index Node 0 Step
            Index Node 1 Step
        Upload Data Phase
            Index Node 0 Step
            Index Node 1 Step
    Data Backup Plan
        Data Backup Phase
            Data Node 0 Step
            Data Node 1 Step
            Data Node 2 Step

As you can see, in addition to the default Deployment and Recovery Plans, this Scheduler also has a custom Update Plan which provides custom logic for rolling out a change to the service. If a custom plan is not defined then the Deployment Plan is used for this scenario. In addition, the service defines auxiliary Plans that support other custom behavior, specifically one Plan that handles backing up Index nodes, and another for that backs up Data nodes. In practice, there would likely also be Plans for restoring these backups. These auxiliary Plans could all be invoked manually by an operator, and may include additional parameters such as credentials or a backup location. Those are omitted here for brevity.

In short, Plans are the SDK’s abstraction for a sequence of tasks to be performed by the Scheduler. By default, these include deploying and maintaining the cluster, but additional maintenance operations may also be fit into this structure.

## Custom Update Plan

By default, the service will use the Deployment Plan when rolling out a configuration change or software upgrade, but some services may need custom logic in this scenario, in which case the service developer may have defined a custom plan named update.

# Virtual networks

The SDK allows pods to join virtual networks, with the dcos virtual network available by defualt. You can specify that a pod should join the virtual network by using the networks keyword in your YAML definition. Refer to the [Developer Guide](https://mesosphere.github.io/dcos-commons/developer-guide/) for more information about how to define virtual networks in your service.

When a pod is on a virtual network such as the dcos:

    - Every pod gets its own IP address and its own array of ports.
    - Pods do not use the ports on the host machine.
    - Pod IP addresses can be resolved with the DNS: <task_name>.<service_name>.autoip.dcos.thisdcos.directory.
    - You can also pass labels while invoking CNI plugins. Refer to the Developer Guide for more information about adding CNI labels.


# Placement Constraints

Placement constraints allow you to customize where a service is deployed in the DC/OS cluster. Depending on the service, some or all components may be configurable using Marathon operators (reference) with this syntax: field:OPERATOR[:parameter]. For example, if the reference lists [["hostname", "UNIQUE"]], you should use hostname:UNIQUE.

A common task is to specify a list of whitelisted systems to deploy to. To achieve this, use the following syntax for the placement constraint:

   ```shell
   hostname:LIKE:10.0.0.159|10.0.1.202|10.0.3.3
   ```    
You must include spare capacity in this list, so that if one of the whitelisted systems goes down, there is still enough room to repair your service (via pod replace) without requiring that system.

## Regions and Zones

Placement constraints can be applied to zones by referring to the @zone key. For example, one could spread pods across a minimum of 3 different zones by specifying the constraint:

   ```shell
   [["@zone", "GROUP_BY", "3"]]
   ```    
    
    
When the region awareness feature is enabled (currently in beta), the @region key can also be referenced for defining placement constraints. Any placement constraints that do not reference the @region key are constrained to the local region.

# Integration with DC/OS access controls

In DC/OS 1.10 and above, you can integrate your SDK-based service with DC/OS ACLs to grant users and groups access to only certain services. You do this by installing your service into a folder, and then restricting access to some number of folders. Folders also allow you to namespace services. For instance, staging/nifi and production/nifi.

Steps:

    1. In the DC/OS GUI, create a group, then add a user to the group. Or, just create a user. Click Organization > Groups > + or Organization > Users > +. If you create a group, you must also create a user and add them to the group.

    2. Give the user permissions for the folder where you will install your service. In this example, we are creating a user called developer, who will have access to the /testing folder. Select the group or user you created. Select ADD PERMISSION and then toggle to INSERT PERMISSION STRING. Add each of the following permissions to your user or group, and then click ADD PERMISSIONS.

    ```shell
    dcos:adminrouter:service:marathon full
    dcos:service:marathon:marathon:services:/testing full
    dcos:adminrouter:ops:mesos full
    dcos:adminrouter:ops:slave full
    ```    
    Install a service (in this example, nifi) into a folder called test. Go to Catalog, then search for beta-nifi.

    Click CONFIGURE and change the service name to /testing/nifi, then deploy.

    The slashes in your service name are interpreted as folders. You are deploying nifi in the /testing folder. Any user with access to the /testing folder will have access to the service.

**Important:**

    Services cannot be renamed. Because the location of the service is specified in the name, you cannot move services between folders.
    DC/OS 1.9 and earlier does not accept slashes in service names. You may be able to create the service, but you will encounter unexpected problems.

### Interacting with your foldered service

    Interact with your foldered service via the DC/OS CLI with this flag: --name=/path/to/myservice.
    To interact with your foldered service over the web directly, use http://<dcos-url>/service/path/to/myservice. E.g., http://<dcos-url>/service/testing/nifi/v1/endpoints.

