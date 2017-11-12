# Pipelines

## Concepts

The following two concept pictures are from Will Gorman's great [mesoscon presentation](
http://events.linuxfoundation.org/sites/events/files/slides/Continuous%20Delivery%20for%20DC%3AOS%20%20with%20Spinnaker.pdf). They introduce the key concepts that we will use in the following.

*Pipelines* are the key deployment management construct (continuous delivery workflows) in Spinnaker. They consist of a sequence of actions, known as stages. You can pass parameters from stage to stage along the pipeline. You can start a pipeline manually, or you can configure it to be started by automatic triggering events, such as a Jenkins job completing, a new Docker image appearing in your registry, a CRON schedule, or a stage in another pipeline. You can configure the pipeline to emit notifications to interested parties at various points during pipeline execution (such as on pipeline start/complete/fail), by email, SMS or HipChat. The following picture shows a sample pipeline.

![Resources](img/pipe-c01.png)

A *Stage* in Spinnaker is an action that forms an atomic building block for a pipeline. You can sequence stages in a Pipeline in any order, though some stage sequences may be more common than others. Spinnaker provides a number of stages such as Deploy, Resize, Disable, Manual Judgment, and many more. 

![Resources](img/pipe-c02.png)


## Creating Pipelines

* [Creating a pipeline with a deployment stage](#creating-a-pipeline-with-a-deployment-stage)
* [Creating a pipeline with resize stages](#creating-a-pipeline-with-resize-stages)
* [Creating a rolling blue green pipeline](#creating-a-rolling-blue-green-pipeline)


### Creating a pipeline with a deployment stage

Go to the *myapp* *Pipelines* view and select *Create* a new pipeline.

![Resources](img/pipe01.png)

In the following dialog specify *deployment* for the *Pipeline Name*.

![Resources](img/pipe02.png)

In the pipeline editor select *Add stage*.

![Resources](img/pipe03.png)

There are various stage types available. Select the *Deploy* stage.

![Resources](img/pipe04.png)

Next specify the *Stage Name*, and then select *Add server group*.

![Resources](img/pipe041.png)

The following is the same dialog we worked with when we created server groups by hand. Peek back for what to enter, the only difference here is we want ten instances in the server group.

![Resources](img/pipe05.png)

Once done make sure to hit save before leaving the pipeline editor by selecting *Back to Executions*

![Resources](img/pipe06.png)

The new *deployment* pipeline is listed, lets select *Start Manual Execution* to run it.

![Resources](img/pipe07.png)

The pipeline gets into the status *RUNNING*, once the status shows *SUCCESS* we can switch over to the *myapp* *Clusters* view.

![Resources](img/pipe08.png)

The *myapp* *Clusters* view shows the created server group.

![Resources](img/pipe09.png)


### Creating a pipeline with resize stages

Here we create a pipepline that showcases *Resize Server Group* stage type. We target the server group that we created in the previous section.

The first resize stage does a *Scale Down* by 5 instances

![Resources](img/pipe10.png)

The secon resize stage does a *Scale Up* by 5 instances, so that we get our server group back to the 10 instances we started with.

![Resources](img/pipe11.png)

There is a *Manual Judgement* stage inbetween the two just to halt the pipeline so that you can easyily observe the behavior when running the pipeline.


### Creating a rolling blue green pipeline

In this section we create a *rolling blue green pipeline* that will roll in a new version of our server group that we created with the *deployment* pipeline earlier. I will not cover the load balancer setup in this section, see the [edge-lb](EDGE_LB.md) document for that.

The 1st stage *green1* is a *Deploy* stage with which we deploy the first two new instances of our new server group version. *V000* used *nginx:1.11* as image, the new one uses *nginx:1:12*.

![Resources](img/pipe12.png)

Stage *blue1* scales down the old version by 20%.

![Resources](img/pipe13.png)

Next follows the *judge* stage, which is of type *Manual Judgement*. From here there are two pathes *continue* or *rollback*.

![Resources](img/pipe14.png)

The *rollback* stage is of type *Check Precondition Configuration*. It checks whether the judge asked for *rollback*, if true the rest of that pipeline branch gets executed.

![Resources](img/pipe15.png)

Stage *rblue1* scales the old version up by 25%, so that we get back to 10 instances in that server group.

![Resources](img/pipe16.png)

Stage *rgreen2* scales down the new version by 100%, so this will delete the 2 new instances that had been created.

![Resources](img/pipe17.png)

Stage *rgreen* is of type *Destroy Server Group Configuration*, it deletes the at this point empty new server group.

![Resources](img/pipe18.png)

The *continue* stage is of type *Check Precondition Configuration*. It checks whether the judge asked for *continue*, if true the rest of that pipeline branch gets executed.

![Resources](img/pipe19.png)

Stage *green2* scales up the new version by 400%, which gets the new version to 10 instances.

![Resources](img/pipe20.png)

Stage *blue2* scales down the old version by 100%, which gets the old version to zero instances.

![Resources](img/pipe21.png)

We are done with the definition of our pipleine, lets *Start Manual Execution*. The pipeline will run up to the *judge* step.

![Resources](img/pipe22.png)

Checking the *myapp* *Clusters* view we now have the expected two versions. *V000* has 8 instances and *V001* has 2 instances.
Now is the time to check the monitors on how well the new instances are behaving so that we can give the right input on the *judge* step.

![Resources](img/pipe23.png)

If we are not happy with the new instances, then we go to the *judge* step and select *rollback*.

![Resources](img/pipe24.png)

The *rollback* path of the pipeline completes.

![Resources](img/pipe25.png)

Checking the *myapp* *Clusters* view we are back to where we started.

![Resources](img/pipe26.png)

If we are happy with the new instances, then we go to the *judge* step and select *continue*.

![Resources](img/pipe27.png)

The *continue* path of the pipeline completes.

![Resources](img/pipe28.png)

Checking the *myapp* *Clusters* view we have a new server group version that has the same size that the old one had when the pipeline started. The old version is down to zero instances.

![Resources](img/pipe29.png)

