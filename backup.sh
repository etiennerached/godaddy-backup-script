#!/bin/bash
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

dbHost[1]=''
dbName[1]=''
dbUser[1]=''
dbPass[1]=''

dbHost[2]=''
dbName[2]=''
dbUser[2]=''
dbPass[2]=''

#Compress Databases (On=1 / Off=0)
compressDatabases=1

##### Files Configuration #####
#Directory (and subdirectories) to backup. By Default, the godaddy public directory is called "html"
filesPath='html'

#Archive files as Zip(0) or Tar(1)
ZipOrTar=1

#Compress Files in Archive? (On=1, Off=0)
#Note: Godaddy scripts are usually interrupted after a specific time. Compressing/deflating the files will take more time to complete. Use zero if you have a huge website and the script is always interrupted.
compressFiles=0

##### FTP Configuration #####
#Note: Using FTP is not secure, use it at your own risk. Your password will be stored in this file in plain text, and can be read by a simple ps command upon execution by others.
#Godaddy blocks most of the outbound ports, including port 21. If you have a FTP with an unblocked port, you can use this option, otherwise keep it disabled.
#Enable FTP Transfer (Yes=1 / No=0)
enableFtpTransfer=0

#FTP Host
FtpHost=''

#FTP Port
FtpPort=''

#FTP User
FtpUser=''

#FTP Password
FtpPass=''

#FTP Path
FtpPath=''


################# End Of Configuration ###################


################# Script Execution #####################
# Edit at your own risk ###

#Store Current Date
Date=`date '+%m-%d-%Y_%H-%M'`

#Create Final Backup Directory
backupDirectory="$backupDirectory/$Date"

#Check if backup directory exist, otherwise create it
if [ ! -d "$HOME/$backupDirectory" ]
then
    mkdir -p $HOME/$backupDirectory/
    echo "Directory Created"
fi

#Backup Databases
for i in ${!dbHost[@]}
do
  if [ $compressDatabases -eq 1 ]
    then
      filename[i]="$HOME/$backupDirectory/${dbName[$i]}_$Date.sql.gz"
      mysqldump -h ${dbHost[$i]} -u ${dbUser[$i]} -p${dbPass[$i]} ${dbName[$i]} | gzip > ${filename[i]}
    else
      filename[i]="$HOME/$backupDirectory/${dbName[$i]}_$Date.sql"
      mysqldump -h ${dbHost[$i]} -u ${dbUser[$i]} -p${dbPass[$i]} ${dbName[$i]} > ${filename[i]}
  fi
done


#Backup Files
cd $HOME/$filesPath

#Zip
if [ $ZipOrTar -eq 0 ]
then
    if [ $compressFiles -eq 0 ]
    then
        filesname="$HOME/$backupDirectory/files_$Date.zip"
        zip -r -0 $filesname * .[^.]*
    else
        filesname="$HOME/$backupDirectory/files_$Date.zip"
        zip -r -9 $filesname * .[^.]*
    fi
fi

#Tar
if [ $ZipOrTar -eq 1 ]
then
    if [ $compressFiles -eq 0 ]
    then
        filesname="$HOME/$backupDirectory/files_$Date.tar"
        tar -cvf $filesname .
    else
        filesname="$HOME/$backupDirectory/files_$Date.tar.gz"
        tar -zcvf $filesname .
    fi
fi


#FTP Transfer
if [ $enableFtpTransfer -eq 1 ]
then
    if [ "$FtpPath" == "" ]
    then
        FtpPath="$Date"
    else
        FtpPath="$FtpPath/$Date"
    fi
#Upload Database(s)
ftp -nv $FtpHost $FtpPort  << END
user $FtpUser $FtpPass
mkdir $FtpPath
cd $FtpPath
lcd $HOME/$backupDirectory
mput *
bye
END
fi
