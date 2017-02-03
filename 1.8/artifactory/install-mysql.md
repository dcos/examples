##MySQL Installation Guide for DC/OS

## Steps to Set Up MySQL:

1. Select MySQL package from Universe.
![MySQL Package in Universe](images/Universe_MySQL.png)

2. Click on Install.

3. Select Advanced Installation and change to the `database` tab. Set the name to `artdb`, the username to `jfrogdcos` and the password to `jfrogdcos`. You can change the root password to whatever you like.

![MySQL Database Options](images/MySQL_Database.png)

4. Change to the `networking` tab. Tick the `host_mode` checkbox to use port `3306`. Once this is done, go ahead and install.

![MySQL Networking Options](images/MySQL_Networking.png)

5. Make sure MySQL is running and is healthy by looking under the Services tab in the DC/OS UI.

![MySQL Health in DC/OS UI](images/MySQL_Health.png)


Bingo! Now you can install Artifactory Pro or Artifactory Enterprise.
*[Here is guide to install Artifactory Pro in DC/OS](Artifactory-Pro.md)
