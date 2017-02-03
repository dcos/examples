##Artifactory-lb Installation Guide for DC/OS

## To Set Up Artifactory-lb in DC/OS following are prerequisites:
1. **Running Artifactory**

## It requires min 1 Public Slave to install Artifactory Pro or Enterprise

## Steps to install Artifactory-lb:

1. Select Artifactory-lb package from Universe.
![Artifactory-lb Package in Universe](images/Universe_Artifactory-lb.png)

2. Click on Install -> Advance Installation.
![Artifactory-lb Install Options](images/Artifactory-lb_Install_Options.png)

### NOTE:  If name of your artifactory service is not "artifactory" then change it under artifactory tab. 
###Use pre populated API KEY in case you have changed artifactory password. follow steps 4 to 7 to fetch API KEY.

3. Click Review and Install.

4. Go to your Mesos UI.
![Mesos UI](images/Mesos.png)

5. Select Artifactory -> Artifactory-logs 
![Artifactory Logs directory](images/Artifactory_Logs_Dir.png)

6. Select artifactory.log file and you will see output as following. Copy API key from artifactory.log file as showed in screen shot.
![Artifactory API Key](images/Artifactory_Log.png)

7. Paste selected API key in Artifactory-lb advance installation -> artifactory tab. as follows. Then review and install.
![Artifactory Advance Installation](images/Artifactory-lb_Install_Options.png)

8. Make sure Artifactory-lb is running and its healthy by looking at Marathon UI.
![Artifactory-lb Health in Marathon UI](images/Artifactory-lb_Health.png)

### Awesome!! now you can access artifactory UI by going to public ip of node where Artifactory-lb is running.

Here is how Artifactory UI looks like!!!
![Artifactory UI](images/Artifactory_UI.png)