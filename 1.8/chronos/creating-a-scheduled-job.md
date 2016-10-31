---
post_title: Creating a Scheduled Job with Chronos
---

This tutorial shows how to create a scheduled job using Chronos.
We're going to create a job that runs every 10 seconds and prints the current date.

### Time Estimate

10 Minutes

### Target Audience

- Data Infrastructure Engineers
- Data Scientists
- Devops Engineers

### Prerequisites

- [Install Chronos][1]
- The job needs at least 128MB of RAM and 0.1 CPU cores available in the cluster.

# <a name="chronosinstall"></a>Installing Chronos on DC/OS

1.  From the DC/OS web UI, go to the **Services** tab and click **Chronos** to open its web UI.

1.  In the Chronos UI, click the **New Job** link to bring up the form for creating jobs.

    ![Chronos in the services view](../img/ui-chronos-new-job.png)

1.    Fill in the following values:

    * NAME: "Date"
    * DESCRIPTION: "Prints the current date"
    * COMMAND: "/bin/date"
    * OWNER(S): Enter your email address.
    * SCHEDULE: Enter "T10S" in the "P" field

    Chronos uses ISO 8601 Interval Notation to describe job schedules. "T10S" means run this job every 10 seconds. For details, see the [ISO 8601 Wikipedia article](https://en.wikipedia.org/wiki/ISO_8601#Time_intervals).

    Click the **Create** button at the top to submit the job to Chronos.

1.  Let's verify that our job ran successfully. Run the following CLI command to view all completed tasks:

    ```bash
    $ dcos task --completed ct*
    ```

    The `--completed` argument includes tasks that have completed their execution. Chronos uses the prefix `ct` for all its tasks, so `ct*` filters only Chronos tasks.

    The output should look similar to this:

    ```bash
    NAME                    HOST        USER  STATE  ID
    ChronosTask:Date        10.0.0.252  root    F    ct:1460844479000:0:Date:
    ChronosTask:Date        10.0.0.252  root    F    ct:1460844559000:0:Date:
    ChronosTask:Date        10.0.0.252  root    F    ct:1460844569000:0:Date:
    ```

1.  To view the output of a task, copy one of the values under the `ID` column in the output of the previous command, and use it as the argument to `dcos task log`:

    ```bash
    $ dcos task log --completed ct:1460844479000:0:Date:
    ```

    The output should look similar to this, and include a line with the current date:

    ```bash
    Registered executor on 10.0.0.252
    Starting task ct:1460844479000:0:Date:
    Forked command at 15344
    sh -c '/bin/date'
    Sat Apr 16 22:07:59 UTC 2016
    Command exited with status 0 (pid: 15344)
    ```

# Appendix: Next Steps

- [Chronos documentation on Github][2]

 [1]: /docs/1.8/usage/tutorials/chronos/
 [2]: http://mesos.github.io/chronos/
