# Automation_Project

This Project contains a bash script to automate the installation of Apache web server on a Ubuntu machine to check various conditions. It create a .tar file of the Apache logs log with a specific file name format and transfer it in s3 buket. The data of the logs are appended to a file called inventory.html which is created in /var/www/html directory. A corn  job is created in the script to run the above funtionalities daily.
