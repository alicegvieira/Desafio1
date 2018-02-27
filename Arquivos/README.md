# Desafio1

###### Metabase application was configurated to run as a service on server using MySql database
###### Read requirements to run desafio1 at 'requirements.txt'

## Path details
###### /backup
Store application .jar old versions backup at '/backup/application' and database backup at '/backup/database'

###### /deploy
Store the files to run the deployment and deployment logs at '/deploy/logs'

**WARN: do not move or remove any '.conf' file from 'deploy' path**

###### /release
Where the application new .jar version is expected after building release from development team

###### /service
Store files to configurate application service

**WARN: do not move or remove any '.conf' file from 'service' path**

## Service configuration details
###### Metabase configuration
File '/service/metabase.conf' contains essential configuration to run metabase application. The content is from metabase documentation with modifications. If not using the Enviroment Teste, is important to configure the variables from the new enviroment 

###### Metabase service configuration
File 'service/service.conf' contains the configuration to run metabase application as a service. The content is from metabase documentation with modifications. If not using the Enviroment Teste, is important to configure the variables from the new enviroment 

## Deployment configuration details
###### Deployment configuration
File '/deploy/deploy.conf' contains essential configuration to run metabase application deployment script. If not using the Enviroment Teste, is important to configure the variables from the new enviroment 

###### Deployment script
File '/deploy/deployscript.sh' contains the script to run metabase application deployment. If not using the Enviroment Teste, is important to update the path at the beggining of this file, when loading the source at: 'source "/alice/desafio1/deploy/deploy.conf"'.

## Deployment details for testing
**WARN: Do not need to change any configuration file to test the script in this enviroment**

**WARN: The script expects that the new metabase release .jar it will be stored at '/release' path. If the script find more than 1 file at this path it will work with the latest one**

There are versioned .jar files at '/deploy/testefiles/' to use as test

## Steps to test first deployment (it will install the service)
- Copy application version file '/deploy/testefiles/metabase.jar' to release path '/release'
- Run the script '/deploy/deployscript.sh' using sudo

**INFO: Script will log at both console and log file at '/deploy/logs'**
After the  service successfully start, browse 'http://localhost:3000' to acess the application

The service name can be changed at '/deploy/deploy.conf', metabase is the default

As the application is a service, it can be used the following commands to start, stop or restart the application:
 - sudo service metabase start
 - sudo service metabase stop
 - sudo service metabase restart

**INFO: If an unhandled error occurr during the installation step, it is recommended to check the service file at '/etc/init.d/metabase' and the official metabase log file at '/var/log/metabase.log' and then run the service uninstall to remove any created file during the process (the deployment script does not perfom uninstall because this step remove files that can be important to understand errors). After uninstall check if the metabase .jar it is at release path '/release' and run the deployment script again.** 

## Testing following deployments (it will update the service)
- Copy the new application version file '/deploy/testefiles/metabase_1_2.jar' to release path '/release'
- Run the script '/deploy/deployscript.sh' using sudo

**INFO: When updating version, the script will move actual running .jar from service path 'service' to backup path '/backup/application'. If some error occurr during the update, the script will stop updating and will rollback to the older .jar that was running before trying updating. If the service stops responding to service commands, force the service to respond using the following commands:**

 - sudo bash /etc/init.d/metabase start 
 - sudo bash /etc/init.d/metabase stop
 - sudo bash /etc/init.d/metabase restart
 
