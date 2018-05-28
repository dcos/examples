# How to use NexCloud with DC/OS

[NexCloud][nexcloud] is the container monitoring and performance management solution specialized in Docker, Apache Mesos, Marathon, DC/OS, Mesosphere, Kubernetes(Soon). In this beta version, it support fundamental function to monitor and analyze container cluster(Mesos, DC/OS, Mesosphere), Container, Agent and basic root cause functionality for event management with on-premise version. At next beta and SaaS version, it will provide more rich functionality for root cause (event management, resource tracing, performance monitor and transaction tasing, etc) soon.

* Estimated time for completion: 5 minutes
* Target audience: Cluster operators and application teams
* Scope: Deploy NexCloud for full-stack monitoring

## Prerequisites

* A running DC/OS 1.10 cluster
* A Dynatrace environment (try for free [here][freetrial])
* [InfluxDB](https://universe.dcos.io/#/package/influxdb/version/latest)  
* [MySQL](https://universe.dcos.io/#/package/mysql/version/latest) / [MySQL-admin](https://universe.dcos.io/#/package/mysql-admin/version/latest)  
If you completed to install MySQL admin, go to MySQL admin and execute next queries.
    ```sql
    CREATE TABLE `nex_config` (
        `code` VARCHAR(64) NOT NULL COMMENT 'Code Name' COLLATE 'utf8_general_ci',
        `value` TEXT NOT NULL COMMENT 'Data' COLLATE 'utf8_general_ci'
    )
    COLLATE='latin1_swedish_ci'
    ENGINE=InnoDB;


    INSERT INTO `nex_config` (`code`, `value`) VALUES
    ('influxdb', 'http://influxdb.marathon.l4lb.thisdcos.directory:8086'),
    ('kafka_host', 'broker.kafka.l4lb.thisdcos.directory'),
    ('kafka_mesos_group', 'workflow_consumer'),
    ('kafka_notification_group', 'assurance_consumer'),
    ('kafka_port', '9092'),
    ('kafka_zookeeper', 'master.mesos:2181/dcos-service-kafka'),
    ('mesos_topic', 'data_collector'),
    ('mesos_endpoint', 'http://leader.mesos'),
    ('mesos_influxdb', 'nexclipper'),
    ('mesos_snapshot_topic', 'data_snapshot'),
    ('notification_topic', 'data_assurance'),
    ('redis_host', 'redis.marathon.l4lb.thisdcos.directory'),
    ('redis_port', '6379'),
    ('scretKey', 'TjRihTXJiMQMvxtOGcLYDqIXgaQJDuLYWYqyCEaxrsOuKULKqKjvgltroQrpGkIP'),
    ('uid', 'admin@nexcloud.co.kr'),
    ('kafka_snapshot_group', 'snapshot_consumer');
    ```
    
    ```sql
    CREATE TABLE `nex_node` (
        `node_name` VARCHAR(64) NOT NULL COMMENT 'Node name',
        `node_ip` VARCHAR(32) NOT NULL COMMENT 'Node IP',
        `node_id` VARCHAR(64) NOT NULL COMMENT 'Node ID',
        `role` VARCHAR(64) NOT NULL COMMENT 'role(agent, master)',
        `parent` VARCHAR(64) NULL DEFAULT NULL COMMENT 'parent host info',
        `status` VARCHAR(2) NOT NULL COMMENT 'Node Status',
        `regdt` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Registered date',
        UNIQUE INDEX `node_ip` (`node_ip`)
    )
    COLLATE='utf8_general_ci'
    ENGIN
    E=InnoDB;
    ```
    ```sql
    CREATE TABLE `nex_notification` (
        `idx` INT(11) NOT NULL AUTO_INCREMENT,
        `severity` ENUM('Critical','Warning') NOT NULL DEFAULT 'Critical' COMMENT 'Grade of notification( Critical, Warning)' COLLATE 'utf8_general_ci',
        `target_system` VARCHAR(32) NULL DEFAULT NULL COMMENT 'Notify from ( \'Host\',\'Agent\',\'Task\',\'Framework\',\'Docker\' )' COLLATE 'utf8_general_ci',
        `target_ip` VARCHAR(32) NULL DEFAULT NULL COMMENT 'IP Where notification occured' COLLATE 'utf8_general_ci',
        `target` VARCHAR(124) NULL DEFAULT NULL COMMENT 'Notify for( CPU, Memory, Disk, Netowrk, System Error..... )' COLLATE 'utf8_general_ci',
        `metric` VARCHAR(512) NULL DEFAULT NULL COMMENT 'Metric for notify' COLLATE 'utf8_general_ci',
        `condition` VARCHAR(512) NULL DEFAULT NULL COMMENT 'Condition' COLLATE 'utf8_general_ci',
        `id` VARCHAR(512) NULL DEFAULT NULL COMMENT 'Service ID or IP of service/Task/Node/Framework' COLLATE 'utf8_general_ci',
        `status` ENUM('S','F') NULL DEFAULT 'S' COMMENT 'Status (\'S\':Started, \'F\':Finished)' COLLATE 'utf8_general_ci',
        `start_time` TIMESTAMP NULL DEFAULT NULL COMMENT 'Start time',
        `finish_time` TIMESTAMP NULL DEFAULT NULL COMMENT 'Finish time',
        `contents` TEXT NOT NULL COMMENT 'Detail of notification' COLLATE 'utf8_general_ci',
        `memo` TEXT NULL COLLATE 'utf8_general_ci',
        `check_yn` CHAR(1) NOT NULL DEFAULT 'N' COLLATE 'utf8_general_ci',
        `regdt` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        PRIMARY KEY (`idx`),
        INDEX `severity` (`severity`),
        INDEX `target_system` (`target_system`),
        INDEX `target_ip` (`target_ip`),
        INDEX `id` (`id`),
        INDEX `status` (`status`),
        INDEX `start_time` (`start_time`),
        INDEX `finish_time` (`finish_time`),
        INDEX `regdt` (`regdt`)
    )
    COLLATE='latin1_swedish_ci'
    ENGINE=InnoDB;
    ```
* [Redis](https://universe.dcos.io/#/package/redis/version/latest)
* [Kafka](https://universe.dcos.io/#/package/kafka/version/latest)


## Install NexCloud

To monitor cluster nodes and applications running in DC/OS simply deploy NexCloud OneAgent to agent nodes by means of the DC/OS package. NexCloud will automatically start monitoring of the nodes and applications.



### Installation on DC/OS agent nodes

Go to the DC/OS universe/catalog web UI and search for "NexCloud". Click the tile and select "Configure" to enter the required parameters for connecting with NexCloud.

Click the tile and select "Configure" to enter the required parameters for connecting with NexCloud.

1. Get your NexCloud OneAgent Download URL from your NexCloud environment

2. Set the number of instances to the number of DC/OS agent nodes


## Additional resources

The NexCloud DC/OS integration is supported by NexCloud.
In case of issues please consult Dynatrace Support.

[nexcloud]: http://www.nexcloud.co.kr/
[freetrial]: https://github.com/nexclouding/NexCloud
