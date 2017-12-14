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

################# Script Execution ###################

###!!! Edit at your own risk !!!###

#What directory is this script in?
#We use this so we know where our config.sh and any db .cnf files are
BASEDIR=$(dirname "$0")

# Get our configuration
. $BASEDIR/config.sh

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
for i in ${!dbName[@]}
do
  filename[i]="$HOME/$thisBackupDirectory/${dbName[$i]}_$Date.sql"
  if [ $compressDatabases -eq 1 ]
    then
      filename+=".gz"
      mysqldump --defaults-extra-file="$BASEDIR/${dbCnf[$i]}" ${dbName[$i]} | gzip > ${filename[i]}
    else
      mysqldump --defaults-extra-file="$BASEDIR/${dbCnf[$i]}" ${dbName[$i]} > ${filename[i]}
  fi
done
##### END OF Backup Databases #####

##### Backup Files #####
toCompress=""

for i in ${!filesPath[@]}
do
  toCompress+="${filesPath[$i]}"
  toCompress+=" "
done

# resulting name of the archive containing the backed up files
# not including the extension
filesname="$HOME/$thisBackupDirectory/files_$Date"

#Zip
if [ $ZipOrTar -eq 0 ]
then
    # change directory to $HOME
    pushd $HOME
    # .zip
    filesname+=".zip"
    if [ $compressFiles -eq 0 ]
    then
        zip -r -0 $filesname $toCompress
    else
        zip -r -9 $filesname $toCompress
    fi
    # return to the previous directory
    popd
fi

#Tar
if [ $ZipOrTar -eq 1 ]
then
    filesname+=".tar"
    if [ $compressFiles -eq 0 ]
    then
        tar -cvf $filesname -C $HOME $toCompress
    else
        filesname+=".gz"
        tar -zcvf $filesname -C $HOME $toCompress
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

##### Delete local old backups #####
#get list of directories in backup folder
if [ $deleteLocalOldBackupsAfter -gt 0 ]
then
    listing=`ls -1 $HOME/$backupDirectory`
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
       	#echo "${lista[i]} - $dateDifferenceInDays"
        if [ $dateDifferenceInDays -gt $deleteLocalOldBackupsAfter ]
        then
            echo "  deleting"
            rm -rf $HOME/$backupDirectory/${lista[i]}
        fi
    done
fi #END OF if [ $deleteLocalOldBackupsAfter -gt 0 ]
##### END OF Delete local old backups #####

################# END OF Script Execution ###################
