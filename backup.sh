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
# http://www.tech-and-dev.com/2013/10/backup-godaddy-files-and-databases.html
# Portions created by the Initial Developer are Copyright (C) 2013
# the Initial Developer. All Rights Reserved.
#
# Contributor(s):
#
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
filesPath='html'

#Archive files as Zip(0) or Tar(1)
ZipOrTar=1

#Compress Files in Archive? (On=1, Off=0)
#Note: Godaddy scripts are usually interrupted after a specific time. Compressing/deflating the files will take more time to complete. Use zero if you have a huge website and the script is always interrupted.
compressFiles=0

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

#FTP Path
FtpPath='/'

################# End Of Configuration ###################


################# Script Execution ###################

###!!! Edit at your own risk !!!###

#Store Current Date
Date=`date '+%Y-%m-%d_%H-%M'`

#Create Final Backup Directory
thisBackupDirectory="$backupDirectory/$Date"

#Check if backup directory exist, otherwise create it
if [ ! -d "$HOME/$thisBackupDirectory" ]
then
    mkdir -p $HOME/$thisBackupDirectory/
    echo "Directory Created"
fi

##### Backup Databases #####
for i in ${!dbHost[@]}
do
  if [ $compressDatabases -eq 1 ]
    then
      filename[i]="$HOME/$thisBackupDirectory/${dbName[$i]}_$Date.sql.gz"
      mysqldump -h ${dbHost[$i]} -u ${dbUser[$i]} -p${dbPass[$i]} ${dbName[$i]} | gzip > ${filename[i]}
    else
      filename[i]="$HOME/$thisBackupDirectory/${dbName[$i]}_$Date.sql"
      mysqldump -h ${dbHost[$i]} -u ${dbUser[$i]} -p${dbPass[$i]} ${dbName[$i]} > ${filename[i]}
  fi
done
##### END OF Backup Databases #####

##### Backup Files #####
cd $HOME/$filesPath

#Zip
if [ $ZipOrTar -eq 0 ]
then
    if [ $compressFiles -eq 0 ]
    then
        filesname="$HOME/$thisBackupDirectory/files_$Date.zip"
        zip -r -0 $filesname * .[^.]*
    else
        filesname="$HOME/$thisBackupDirectory/files_$Date.zip"
        zip -r -9 $filesname * .[^.]*
    fi
fi

#Tar
if [ $ZipOrTar -eq 1 ]
then
    if [ $compressFiles -eq 0 ]
    then
        filesname="$HOME/$thisBackupDirectory/files_$Date.tar"
        tar -cvf $filesname .
    else
        filesname="$HOME/$thisBackupDirectory/files_$Date.tar.gz"
        tar -zcvf $filesname .
    fi
fi
##### END OF Backup Files #####

######## FTP Transfer ########
##### Transfer Files #####
if [ $enableFtpTransfer -eq 1 ]
then
    if [ "$FtpPath" == "" ]
    then
        FtpPath="$Date"
    else
        FtpPath="$FtpPath/$Date"
    fi
#Upload File & Database(s)
ftp -npv $FtpHost $FtpPort  << END
user $FtpUser $FtpPass
mkdir $FtpPath
cd $FtpPath
lcd $HOME/$thisBackupDirectory
prompt off
mput *
bye
END
##### END OF Transfer Files #####

##### Delete Old Backups #####
    #get list of directories in ftp
    if [ $deleteOldBackupsAfter -gt 0 ]
    then
        listing=`ftp -inp $FtpHost $FtpPort  << EOF
user $FtpUser $FtpPass
ls -1R
bye
EOF
`
        lista=( $listing )
        toDelete=""

        #loop through the list and compare
        for i in ${!lista[@]}
        do
            dirToDate=`cut -d "_" -f 1 <<< "${lista[i]}"`
            dateToTimestamp=`date -d "$dirToDate" +%s`
	    if ! [[ $dateToTimestamp =~ ^-?[0-9]+$ ]]
            then
                continue
            fi
            currentDateInTimestamp=`date +"%s"`
            dateDifference=$((currentDateInTimestamp-dateToTimestamp))
            dateDifferenceInDays=$(($dateDifference/3600/24))
            if [ $dateDifferenceInDays -gt $deleteOldBackupsAfter ]
            then
                toDelete="${toDelete}mdelete ${lista[i]}/*
                rmdir ${lista[i]}
                "
            fi
        done

        #delete old files
        if [ "$toDelete" != "" ]
        then
        ftp -inpv $FtpHost $FtpPort  << EOF
user $FtpUser $FtpPass
$toDelete
bye
EOF
        fi #END OF if [ "$toDelete" != "" ]
    fi #END OF if [ $deleteOldBackupsAfter -gt 0 ]
##### END OF Delete Old Backups #####

##### Delete local files #####
    if [ $deleteFilesAfterTransfer -eq 1 ]
    then
	echo "Deleting local file: " $HOME/$thisBackupDirectory;
        rm -rf $HOME/$thisBackupDirectory
    fi #END [ $deleteFilesAfterTransfer -eq 1 ]
##### END OF Delete local files #####

fi #END [ $enableFtpTransfer -eq 1 ]
######## END OF FTP Transfer ########

################# END OF Script Execution ###################
