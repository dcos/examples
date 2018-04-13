---
post_title: Uninstall
menu_order: 30
enterprise: 'no'
---

## DC/OS 1.10

If you are using DC/OS 1.10 :

Uninstall the service from the DC/OS CLI, by entering `dcos package uninstall <package_name> --app-id=<app-id>`.
For example, to uninstall the Apache Nifi instance named nifi-dev, run:

```shell
dcos package uninstall --app-id=nifi-dev nifi
```

### Uninstall Flow

Uninstalling the service consists of the following steps:

  The scheduler is relaunched in Marathon with the environment variable SDK_UNINSTALL set to “true”. This puts the Scheduler in an uninstall mode.
  
    The scheduler performs the uninstall with the following actions:
    
        1. All running tasks for the service are terminated so that Mesos will reoffer their resources.
        2. As the task resources are offered by Mesos, they are unreserved by the scheduler.
            Warning: Any data stored in reserved disk resources will be irretrievably lost.
        3. Once all known resources have been unreserved, the scheduler’s persistent state in ZooKeeper is deleted.
        
    The cluster automatically removes the scheduler task once it advertises the completion of the uninstall process.

Note that once the uninstall operation has begun, it cannot be cancelled because it can leave the service in an uncertain, half-destroyed state.

### Debugging an uninstall

In the vast majority of cases, this uninstall process goes off without a hitch. However, in certain situations, there can be snags along the way. For example, perhaps a machine in the cluster has permanently gone away, and the service being uninstalled had some resources allocated on that machine. This can result in the uninstall becoming stuck, because Mesos will never offer those resources to the uninstalling scheduler. As such, the uninstalling scheduler will not be able to successfully unreserve the resources it had reserved on that machine.

This situation is indicated by looking at deploy plan while the uninstall is proceeding. The deploy plan may be viewed using either of the following methods:

    1. CLI: dcos nifi --name=nifi plan show deploy (after running dcos package install --cli nifi if needed)
    2. HTTP: https://yourcluster.com/service/nifi/v1/plans/deploy
    
```shell
dcos nifi --name=nifi plan show deploy
deploy (IN_PROGRESS)
├─ kill-tasks (COMPLETE)
│  ├─ kill-task-node-0-server__1a4114bc-48bb-47f6-be99-1b5ca6d55c4e (COMPLETE)
│  ├─ kill-task-node-1-server__0c42118e-04fd-40e1-b49d-0d3f71d2d243 (COMPLETE)
│  └─ kill-task-node-2-server__e00cad38-f27f-4332-b1df-5118ca480d50 (COMPLETE)
├─ unreserve-resources (IN_PROGRESS)
│  ├─ unreserve-f41351a2-b478-4e13-a94c-705f530989ef (COMPLETE)
│  ├─ unreserve-48f64612-8427-4cde-86f4-4edeb9efff37 (COMPLETE)
│  ├─ unreserve-402d51f5-6014-4ca3-bd13-324dae62b888 (PENDING)
│  ├─ unreserve-cb95e869-277f-48b9-954f-08c0d7a26bcf (PENDING)
│  ├─ unreserve-cbd748d0-df7b-4d01-b0b7-6acf915d8f98 (COMPLETE)
│  ├─ unreserve-00ed63d6-427c-4492-9713-772390cc5241 (COMPLETE)
│  ├─ unreserve-5dd56b1d-4522-4bbd-88b5-de9fa0f181f2 (PENDING)
│  └─ unreserve-c9915f07-f446-4e14-a6b4-12c8dd2f914b (COMPLETE)
└─ deregister-service (PENDING)
└─ deregister (PENDING)  
```    
As we can see above, some of the resources to unreserve are stuck in a PENDING state. We can force them into a COMPLETE state, and thereby allow the scheduler to finish the uninstall operation. This may be done using either of the following methods:

    1. CLI: dcos nifi --name=nifi plan show deploy
    2. HTTP: https://yourcluster.com/service/nifi/v1/plans/deploy/forceComplete?phase=unreserve-resources&step=unreserve-<UUID>
    
At this point the scheduler should show a COMPLETE state for these steps in the plan, allowing it to proceed normally with the uninstall operation:

```shell
dcos nifi --name=nifi plan show deploy
deploy (IN_PROGRESS)
├─ kill-tasks (COMPLETE)
│  ├─ kill-task-node-0-server__1a4114bc-48bb-47f6-be99-1b5ca6d55c4e (COMPLETE)
│  ├─ kill-task-node-1-server__0c42118e-04fd-40e1-b49d-0d3f71d2d243 (COMPLETE)
│  └─ kill-task-node-2-server__e00cad38-f27f-4332-b1df-5118ca480d50 (COMPLETE)
├─ unreserve-resources (COMPLETE)
│  ├─ unreserve-f41351a2-b478-4e13-a94c-705f530989ef (COMPLETE)
│  ├─ unreserve-48f64612-8427-4cde-86f4-4edeb9efff37 (COMPLETE)
│  ├─ unreserve-402d51f5-6014-4ca3-bd13-324dae62b888 (COMPLETE)
│  ├─ unreserve-cb95e869-277f-48b9-954f-08c0d7a26bcf (COMPLETE)
│  ├─ unreserve-cbd748d0-df7b-4d01-b0b7-6acf915d8f98 (COMPLETE)
│  ├─ unreserve-00ed63d6-427c-4492-9713-772390cc5241 (COMPLETE)
│  ├─ unreserve-5dd56b1d-4522-4bbd-88b5-de9fa0f181f2 (COMPLETE)
│  └─ unreserve-c9915f07-f446-4e14-a6b4-12c8dd2f914b (COMPLETE)
└─ deregister-service (PENDING)
   └─ deregister (PENDING)
```    
    
### Manual uninstall    

If all else fails, one can simply manually perform the uninstall themselves. To do this, perform the following steps:

    1. Delete the uninstalling scheduler from Marathon.
    2. Unregister the service from Mesos using its UUID as follows:
    
```shell
dcos service --inactive | grep nifi
nifi     False     3    3.3  6240.0  15768.0  97a0fd27-8f27-4e14-b2f2-fb61c36972d7-0096
dcos service shutdown 97a0fd27-8f27-4e14-b2f2-fb61c36972d7-0096
```

