#!/bin/bash
# ***** BEGIN LICENSE BLOCK *****
# Version: MPL 2.0
#
# The contents of this file are subject to the Mozilla Public License Version
# 2.0 (the "License"); you may not use this file except in compliance with
# the License. You may obtain a copy of the License at
# http://www.mozilla.org/MPL/
#
# Software distributed under the License is distributed on an "AS IS" basis,
# WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
# for the specific language governing rights and limitations under the
# License.
#
# The Initial Developer of the Original Code is
# Etienne Rached
# https://github.com/etiennerached
# http://www.tech-and-dev.com/2013/10/backup-godaddy-files-and-databases.html
#
# Portions created by the Initial Developer are Copyright (C) 2013
# the Initial Developer. All Rights Reserved.
#
# Contributor(s):
# Andrew Parlane
# https://github.com/andrewparlane
# ***** END LICENSE BLOCK *****

###################### Configuration ######################

#Store the backups in the following directory
#Note: Always backup your data outside of your public_html or html directory. This will ensure your backup files won't be accessed publicly from a browser.
#Example:
#backupDirectory="backup/mybackupfiles"
backupDirectory="backup"

##### Database Configuration #####
#Databases Information
#You can add as much databases information as you wish
#The database information should be incremental and follow the below format:
#############
#dbHost[0]=''
#dbName[0]=''
#dbUser[0]=''
#dbPass[0]=''
#
#dbHost[1]=''
#dbName[1]=''
#dbUser[1]=''
#dbPass[1]=''
#
#dbHost[2]=''
#dbName[2]=''
#dbUser[2]=''
#dbPass[2]=''
#############
#
#
#Example:
##################################
#dbHost[0]='localhost'
#dbName[0]='database1'
#dbUser[0]='user'
#dbPass[0]='myhardtoguesspassword'
#
#dbHost[1]='db.domain.com'
#dbName[1]='database1'
#dbUser[1]='myusername'
#dbPass[1]='ghjkkjh2678(27'
##################################

dbHost[0]=''
dbName[0]=''
dbUser[0]=''
dbPass[0]=''

#Compress Databases (On=1 / Off=0)
compressDatabases=1

##### Files Configuration #####
#$HOME should by default hold the path of your user home directory, in case it doesn't, or if you want to backup a specific directory, you can define it below:
#HOME="/var/www"

#Directory (and its subdirectories) to backup. By Default, the godaddy public directory is called "html" or "public_html"
#You can define more than one directory, this is useful mostly for MVC frameworks, where it's usually advisable to store the core framework outside of public_html
#Example:
#filesPath[0]='public_html'
#filesPath[1]='yii'
#filesPath[2]='anotherdir'
filesPath[0]='public_html'


#Archive files as Zip(0) or Tar(1)
ZipOrTar=1

#Compress Files in Archive? (On=1, Off=0)
#Note: Godaddy scripts are usually interrupted after a specific time. Compressing/deflating the files will take more time to complete. Use zero if you have a huge website and the script is always interrupted.
compressFiles=0

#How many days should the backup remain locally before it's deleted. Set to 0 to disable it.
deleteLocalOldBackupsAfter=60

##### FTP Configuration #####
#Note: Using FTP is not secure, use it at your own risk. Your password will be stored in this file in plain text, and can be read by a simple ps command upon execution by others.
#Enable FTP Transfer (Yes=1 / No=0)
enableFtpTransfer=0

#Delete local files after uploading them to FTP (Yes=1 / No=0). This will only work if enableFtpTransfer is set to 1
deleteFilesAfterTransfer=1

#How many days should the backup remain in the ftp before it's deleted. Set to 0 to disable it. This will only work if enableFtpTransfer is set to 1
deleteOldBackupsAfter=30

#FTP Host - Fill the FTP details below. This is only required if enableFtpTransfer is set to 1
FtpHost=''

#FTP Port
FtpPort=''

#FTP User
FtpUser=''

#FTP Password
FtpPass=''

#FTP Path - Leave empty if you want to upload on the FTP root directory
FtpPath=''

################# End Of Configuration ###################

