godaddy-backup-script
=====================

Automatically Backup Files and Databases
========================================

The script was initially built for godaddy shared hosting. However, as of 2014-12-26, the script will now work on any host that can run bash scripts, including VPS and dedicated servers.

Make sure to fill in config.sh with your settings and to create the relevant database .cnf files before running the script.

In order to run the script automatically, a cron job needs to be setup. To setup a Cron job, go to your Web Hosting Panel (CPanel, Plesk, etc...), and search for "Cron Job Manager". Create a new cron job, and choose how often do you want the backup to occur.

More info on how to install and run can be found on: http://www.tech-and-dev.com/2013/10/backup-godaddy-files-and-databases.html

Manual Restore Files and Databases
==================================

restore.sh now lets you restore a previously made backup.

Run ./restore.sh path/to/backup/folder/date_of_backup

BE CAREFUL WITH THIS. Make sure you have at least one good backup stored off the server first, just in case. I have tested this on my own setup and it works, but there are no guarantees that it is bug free.

It moves existing files that would be replaced by the backup to $HOME/tmp_replaced_on_DATE_HERE allowing you to manually restore them if the restore fails. This folder should be deleted manually when everything is confirmed OK

Additionally $HOME/tmp_restore_dir_$Date is created. It should only consist of empty directories (if any) after a successfull restore. You should delete this manually once you are sure the restore was successfull

2017/12/14 Update:
==================
Moved configuration to config.sh

Create backups relative to $HOME instead of /

Use database credential files (*.cnf) for mysqldump so you don't have to pass the password over the cmdline

Added a restore script to let you restore a backup

2014/12/26 Update:
==================
With the correct configurations the script will now work on any host that can run bash scripts, including VPS and dedicated servers.

Added ability to delete backups from the backup FTP after X days.

Added ability to delete local files after the transfer to the backup FTP is completed successfully.

Users can now define the home directory.

Fixed a bug that weren't copying all the files successfully to the FTP

Added Passive mode while connecting to FTP

NOTE: The date format that is stored on the backup FTP has been changed from MM-DD-YYYY to YYYY-MM-DD
