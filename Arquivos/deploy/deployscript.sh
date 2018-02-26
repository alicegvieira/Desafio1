#! bin/bash

#Bash to execute script to deploy Metabase application

echo $(date --rfc-3339=seconds) '| Loading configurations from file ''deploy_conf'''
source "/alice/desafio1/deploy/deploy.conf"

echo $(date --rfc-3339=seconds) "| It will create log file '$logfile'"
sudo touch $logfile
echo $(date --rfc-3339=seconds) '| Log file created'

#Output to logfile and console
exec > >(tee -i $logfile)
exec 2>&1

echo $(date --rfc-3339=seconds) '| -------------------------------------------------'
echo $(date --rfc-3339=seconds) '| {Database user} = ' $db_user
echo $(date --rfc-3339=seconds) '| {Database password} = ' $db_password
echo $(date --rfc-3339=seconds) '| {Database name} = ' $db_name
echo $(date --rfc-3339=seconds) '| {Database backup file} = ' $db_bkp_file
echo $(date --rfc-3339=seconds) '| {Service name} = ' $service
echo $(date --rfc-3339=seconds) '| {Service path} = ' $service_path
echo $(date --rfc-3339=seconds) '| {Service backup path} = ' $service_bkp_path
echo $(date --rfc-3339=seconds) '| {Service release path} = ' $service_rls_path
echo $(date --rfc-3339=seconds) '| {Metabase configuration file} = ' $metabase_conf_file
echo $(date --rfc-3339=seconds) '| {Service user} = ' $service_user
echo $(date --rfc-3339=seconds) '| -------------------------------------------------'
echo $(date --rfc-3339=seconds) '| Finished loading configurations'

echo $(date --rfc-3339=seconds) '| =================================================' 
echo $(date --rfc-3339=seconds) '| -----Metabase application deployment Started-----' 
echo $(date --rfc-3339=seconds) '| ================================================='

echo $(date --rfc-3339=seconds) "| Verifying if service '$service' is installed"

if [ -f "/etc/init.d/$service" ];
then
	echo $(date --rfc-3339=seconds) '| Service is already installed. It will update it'
	echo $(date --rfc-3339=seconds) "| Starting database '$db_name' backup to file '$db_bkp_file'"

	mysqldump -u $db_user -p$db_password -x -e -B $db_name > $db_bkp_file

	if [ -s "$db_bkp_file" ];
	then
		backup=true
		echo $(date --rfc-3339=seconds) '| Database backup successfully finished'
		echo $(date --rfc-3339=seconds) "| It will check service '$service' status"
		running=$(bash /etc/init.d/$service status)

		if [ "$running" = 1 ];
		then
			echo $(date --rfc-3339=seconds) "| Service is running. It will stop it"
			sudo service metabase stop

			echo $(date --rfc-3339=seconds) "| Stopping service..."
			sleep 30

			running=$(bash /etc/init.d/$service status)

			if [ "$running" = 0 ];
			then
				echo $(date --rfc-3339=seconds) "| Service successfully stopped."
				stopped=true
			else
		                echo $(date --rfc-3339=seconds) '| ERROR - Failed to stop service. Deployment cannot continue'
	               		#mandar email
				echo $(date --rfc-3339=seconds) "| Check service log file '/var/log/metabase.log' for more details"
                    		echo $(date --rfc-3339=seconds) '| ================================================='
             			echo $(date --rfc-3339=seconds) '| -----Metabase application deployment Finished----'
             			echo $(date --rfc-3339=seconds) '| ================================================='
				exit
			fi
		else
			echo $(date --rfc-3339=seconds) "| Service is not running"
		fi

		echo $(date --rfc-3339=seconds) '| It will update service metabase .jar'

		for i in $service_path/*.jar; do
    			[ -e "$i" ] || continue
			echo $(date --rfc-3339=seconds) "| It will move actual metabase .jar '$i' to backup path '$service_bkp_path'"
        		mv "$i" $service_bkp_path
			jar="$i"
		done
		actual_jar="${jar/$service_path/$service_bkp_path}"
	else
		echo $(date --rfc-3339=seconds) '| ERROR - Failed to backup database. Deployment cannot continue'
                #mandar email
	     	echo $(date --rfc-3339=seconds) '| ================================================='
             	echo $(date --rfc-3339=seconds) '| -----Metabase application deployment Finished----'
             	echo $(date --rfc-3339=seconds) '| ================================================='
                exit
	fi
else
	echo $(date --rfc-3339=seconds) "| Service is not installed. It will install it at '/etc/init.d/$service'"
	touch /etc/init.d/$service

	echo $(date --rfc-3339=seconds) "| It will create metabase configuration file '/$metabase_conf_file'"
	touch $metabase_conf_file

	echo $(date --rfc-3339=seconds) "| It will create service log '/var/log/metabase.log'"
	touch /var/log/metabase.log

	chown $service_user:$service_user /var/log/metabase.log

	echo $(date --rfc-3339=seconds) "| Service successfully created"
fi

echo $(date --rfc-3339=seconds) "| It will get the most recent metabase .jar at release path '$service_rls_path'"
service_rls_file=$(find $service_rls_path -name '*.jar' -type f -printf '%T@ %p\n' | sort -n | tail -1 | cut -f2- -d" ")

if [ -z "$service_rls_file" ];
then
       	echo $(date --rfc-3339=seconds) '| ERROR - Could not find any .jar file. Deployment cannot continue'
        echo $(date --rfc-3339=seconds) "| It will move back actual service .jar '$actual_jar' to service path '$service_path'"
        mv $actual_jar $service_path

	if [ "$stopped" = true ];
	then
		echo $(date --rfc-3339=seconds) "| Starting service '$service'..."
		service $service start

		sleep 30

                running=$(bash /etc/init.d/$service status)
		if [ "$running" = 1 ];
                then
                        echo $(date --rfc-3339=seconds) "| Service successfully started"
                else
                       	echo $(date --rfc-3339=seconds) '| ERROR - Failed to start service'
			#mandar email
			echo $(date --rfc-3339=seconds) "| Check service log file '/var/log/metabase.log' for more details"
                        echo $(date --rfc-3339=seconds) '| ================================================='
             		echo $(date --rfc-3339=seconds) '| -----Metabase application deployment Finished----'
             		echo $(date --rfc-3339=seconds) '| ================================================='
                       	exit
                fi
	fi
             	echo $(date --rfc-3339=seconds) '| ================================================='
             	echo $(date --rfc-3339=seconds) '| -----Metabase application deployment Finished----'
             	echo $(date --rfc-3339=seconds) '| ================================================='
		exit
else
       	echo $(date --rfc-3339=seconds) "| Found .jar file '$service_rls_file'"
fi

echo $(date --rfc-3339=seconds) "| It will move metabase release .jar to service path '$service_path'"
mv $service_rls_file $service_path
service_jar="${service_rls_file/$service_rls_path/$service_path}"

echo $(date --rfc-3339=seconds) "| It will update service configuration at '/etc/init.d/$service'"

service_rls_file_e="${service_jar//\//\\/}"
metabase_conf_file_e="${metabase_conf_file//\//\\/}"

sed -e "s/\$p1/$service_rls_file_e/" -e "s/\$p2/$metabase_conf_file_e/" -e "s/\$p3/$service_user/" $service_path/service.conf > /etc/init.d/$service

echo $(date --rfc-3339=seconds) "| It will update metabase configuration at '$metabase_conf_file'"
sed -e "s/\$p1/$db_name/" -e "s/\$p2/$db_user/" -e "s/\$p3/$db_password/" $service_path/metabase.conf > $metabase_conf_file

#update service
sudo systemctl daemon-reload
sudo chmod +x /etc/init.d/$service
sudo update-rc.d $service defaults

echo $(date --rfc-3339=seconds) "| Starting service '$service'..."
bash /etc/init.d/$service start

echo $(date --rfc-3339=seconds) "| Configuring service..."

sleep 30

running=$(bash /etc/init.d/$service status)
if [ "$running" = 1 ];
then
	echo $(date --rfc-3339=seconds) "| Service successfully started"
else
	echo $(date --rfc-3339=seconds) '| ERROR - Failed to start service'
        #mandar email
	echo $(date --rfc-3339=seconds) "| Check service log file '/var/log/metabase.log' for more details"
	echo $(date --rfc-3339=seconds) '| ============================================================='
	echo $(date --rfc-3339=seconds) '| ----------Metabase application deployment Finished-----------'
	echo $(date --rfc-3339=seconds) '| ============================================================='
	exit
fi

if [ "$backup" = true ];
then
	echo $(date --rfc-3339=seconds) "| It will compact database backup file to '$db_bkp_file.tar.gz'"
	tar -czvf $db_bkp_file.tar.gz $db_bkp_file

	if [ -s "${db_bkp_file}.tar.gz" ];
	then
		echo $(date --rfc-3339=seconds) '| The database backup file is compacted. It will delete original file'
		rm $db_bkp_file
	else
		echo $(date --rfc-3339=seconds) '| ERROR - Failed to compact database backup file. The original file will remain'
		echo error dont delete file
	fi
fi

echo $(date --rfc-3339=seconds) '| ============================================================='
echo $(date --rfc-3339=seconds) '| -----Metabase application deployment sucessfully Finished----'
echo $(date --rfc-3339=seconds) '| ============================================================='
