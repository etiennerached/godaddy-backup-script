godaddy-backup-script
=====================

Automatically Backup Files and Databases
========================================

The script was initially built for godaddy shared hosting. However, as of 2014-12-26, the script will now work on any host that can run bash scripts, including VPS and dedicated servers.

Make sure to fill the "Configuration" section before running the script.

In order to run the script automatically, a cron job needs to be setup. To setup a Cron job, go to your Web Hosting Panel (CPanel, Plesk, etc...), and search for "Cron Job Manager". Create a new cron job, and choose how often do you want the backup to occur.

More info on how to install and run can be found on: http://www.tech-and-dev.com/2013/10/backup-godaddy-files-and-databases.html

2014/12/26 Update:
==================
With the correct configurations the script will now work on any host that can run bash scripts, including VPS and dedicated servers.

Added ability to delete backups from the backup FTP after X days.

Added ability to delete local files after the transfer to the backup FTP is completed successfully.

Users can now define the home directory.

Fixed a bug that weren't copying all the files successfully to the FTP

Added Passive mode while connecting to FTP

NOTE: The date format that is stored on the backup FTP has been changed from MM-DD-YYYY to YYYY-MM-DD
