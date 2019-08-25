# How to use Artifactory on DC/OS
**&ast;&ast;&ast; *Deprecation NOTICE* &ast;&ast;&ast;**  
*The Artifactory on DC/OS integration is deprecated and no longer maintained. Please use another [installation](https://www.jfrog.com/confluence/display/RTF/Installing+Artifactory) method.*

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

## Notes

[Postgres](install-postgres.md) and [MySQL](install-mysql.md) database options provided in this documentation 
should be sufficient to trial the Artifactory but we do not currently recommend using this database settings
 for a production deployment of Artifactory.

For instructions on how to use Artifactory as a Docker Registry, see [this
guide](using-artifactory.md). If you are planning to setup Artifactory as insecure docker registry,
We recommend to do this setup before running other services.
