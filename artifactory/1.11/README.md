# How to use Artifactory on DC/OS

Currently you are only able to use licensed versions of Artifactory on DC/OS. To
get a trial license, go to [JFrog's
website](https://www.jfrog.com/artifactory/free-trial-mesosphere/).

Artifactory requires a database named `artifactory` made available (MySQL, Oracle, MS
SQL Server or Postgres). To set up a testing instance of Postgres on DC/OS, see
[this guide](install-postgres.md).

Once you have a database available, see the following guides to install the
correct version of Artifactory:

+ For Artifactory Pro, follow [this guide](artifactory-pro.md). 
  
  Artifactory Pro provides universal package management, integration with all leading CI servers, 
  promotion of build artifacts, REST API support and more.
   
+ For Artifactory Enterprise, follow [this guide](artifactory-enterprise.md).
  
  Artifactory Enterprise provides all pro features along with High availability, Disaster recovery and more.

## Resources

For more documentation about JFrog Artifactory please visit
[wiki.jfrog.com](https://wiki.jfrog.com).
