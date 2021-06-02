#! /bin/bash
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

####  Copy .tar to S3 bucket
aws s3 \
cp /tmp/${name}-httpd-logs-${timestamp}.tar \
s3://${s3_bucket}/${name}-httpd-logs-${timestamp}.tar
