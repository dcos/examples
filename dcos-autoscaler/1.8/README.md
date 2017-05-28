# DC/OS Auto-scaling


## Usage
Run this app in your DC/OS either by directly installing it from the universe or by using this marathon json.
```
{
  "id": "/dcos-autoscaler",
  "instances": 1,
  "cpus": 0.5,
  "mem": 500,
  "container": {
    "docker": {
      "image": "ahmadposten/dcos-autoscaling"
    }
  }
}
```

You would need to label your application as autoscalable by adding this label to your application
`AUTOSCALABLE=true`

Specify the minimum and maximum number of instances by
`AUTOSCALING_MIN_INSTANCES=<minumum number>` and `AUTOSCALING_MAX_INSTANCES=<maximum number>`

Rules are specified by adding labels in the format of

`AUTOSCALING_{Rule number}_RULE_{property}`

for example If you wish to scale your application up based on cpu utilization you add the following labels to your application
```
{
  "AUTOSCALABLE": "true",
  "AUTOSCALING_MIN_INSTANCES": "1",
  "AUTOSCALING_MAX_INSTANCES": "10",
  "AUTOSCALING_COOLDOWN_PERIOD": "60",
  "AUTOSCALING_0_RULE_TYPE": "cpu",
  "AUTOSCALING_0_RULE_THRESHOLD": "70",
  "AUTOSCALING_0_RULE_STEP": "2",
  "AUTOSCALING_0_RULE_OPERATOR": "gt",
  "AUTOSCALING_0_RULE_SAMPLES": 5,
  "AUTOSCALING_0_RULE_INTERVAL": 60,
  "AUTOSCALING_0_RULE_ACTION": "increase"
}
```

By these labels I defined that this application will be scalable, it can never go below 1 instance or above 10 instances. After every scaling activity wait for 1 minute before doing another one if needed. If the cpu utilization exceeds 70 for 5 samples of 1 minutes each increase the instances by 2 instances.


## Supported labels

| Label                          | Description                                                                                                                     | Scope       | Possible values    |
|--------------------------------|---------------------------------------------------------------------------------------------------------------------------------|-------------|--------------------|
| AUTOSCALABLE                   | Specifies that your application is supervised by the autoscaler                                                                 | Application | Boolean            |
| AUTOSCALING_MIN_INSTANCES      | Specifies the minimum number of instances that your app need to maintain                                                        | Application | Integer            |
| AUTOSCALING_MAX_INSTANCES      | Specifies the minimum number of instances that your app need to maintain                                                        | Application | Integer            |
| AUTOSCALING_COOLDOWN_PERIOD    | The number of seconds to wait before going on with another scaling activity                                                     | Application | Integer            |
| AUTOSCALING_{X}_RULE_TYPE      | The type of the rule x                                                                                                          | Rule        | cpu, memory        |
| AUTOSCALING_{X}_RULE_THRESHOLD | The threshold of rule x                                                                                                         | Rule        | Double             |
| AUTOSCALING_{X}_RULE_OPERATOR  | The comparison operator (> or <) against the threshold                                                                          | Rule        | gt, lt             |
| AUTOSCALING_{X}_RULE_INTERVAL  | The interval every measurement will be taken over in seconds                                                                    | Rule        | Integer            |
| AUTOSCALING_{X}_RULE_SAMPLES   | The number of consecutive samples to average  and compare to the threshold.  Every sample is taken over the specified interval. | Rule        | Integer            |
| AUTOSCALING_{X}_RULE_ACTION    | The action to take when the rule is triggered.                                                                                  | Rule        | increase, decrease |
| AUTOSCALING_{X}_RULE_STEP    | The step to scale by when rule is triggered.                                                                                  | Rule        | Integer |



