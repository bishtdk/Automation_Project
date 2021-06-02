#!/bin/bash
#### Veriables
name=Deepak
s3_bucket=upgrad-deepak

#####update the package sources list
sudo apt update -y

##### Check installation of Apache2
apstatus=$(sudo systemctl list-unit-files | grep apache2.service | awk '{print $2}')
if  [[ $apstatus == "enabled" ]]
then
        echo "Apache is installed"
else
        echo "Installing Apache......"
        sudo apt install apache2 -y
fi

#### Check status of Apache service
aprunstatus=$(sudo service --status-all | grep apache2 | awk '{print $2}')
if  [[ $aprunstatus == "+" ]]
then
        echo "Apache is running"
else
        echo "Starting Apache ...."
        sudo systemctl start apache2
fi

#### Check if Apache is set to start at system boot
apbootstart=$(sudo systemctl list-unit-files --type=service --state=enabled --all | grep apache2 | awk '{print $2}')
if  [[ $apbootstart == "enabled" ]]
then
        echo "Apache is set to start on system boot"
else
        echo "Setting Apache to start on system boot"
        sudo update-rc.d apache2 defaults
fi

#### Archiving Logs - creating a tar archive of apache2 access logs and error logs
cd /var/log/apache2/

timestamp=$(date '+%d%m%Y-%H%M%S')
tar -cvf /tmp/"$name-httpd-logs-$timestamp.tar"  ./*.log

#### get the size of the file
filesize=$(du -h /tmp/$name-httpd-logs-$timestamp.tar | awk '{print $1}') 

####  Copy .tar to S3 bucket
aws s3 \
cp /tmp/${name}-httpd-logs-${timestamp}.tar \
s3://${s3_bucket}/${name}-httpd-logs-${timestamp}.tar

####look for inventory.html, if not forund create the file
cd /var/www/html/
invfile=inventory.html

if  [ -f "$invfile" ]; then
        echo "inventory.html file is avalable"
else 
        cd /var/www/html
	touch inventory.html   
	echo "<!DOCTYPE html>
		<html>
		<body>
		<table style="width:60%";margin-left:auto;margin-right:auto;> <tr> <th>Log Type</th> <th>Time Created</th> <th>Type</th> <th>Size</th> </tr> </table>
		</body>
		</html>" > inventory.html 

	echo "New inventory.html file Created"
fi

echo  "<!DOCTYPE html>
                <html>
                <body>
                <table style="width:60%";margin-left:auto;margin-right:auto;> <tr> <th>httpd-logs</th> <th>${timestamp}</th> <th>.tar</th> <th>$filesize</th> </tr> </table>
                </body>
                </html>" >> inventory.html

#### Scheduling the script through Cron Job
cronvar=$(sudo service --status-all | grep cron | awk '{print $2}')
if [[ $cronvar == "+" ]]
then
	echo "Cron is active and running"
else
	apt-get install cron
fi

cd /etc/cron.d

cronfile=automation
if [[ -f $cronfile ]]
then
	echo "Automation job is already scheduled"
else
	touch automation
	echo "0 0 * * * /root/Automation_Project/automation.sh" > automation
fi
