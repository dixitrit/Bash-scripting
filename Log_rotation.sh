#!/bin/bash

#########################################################
### This script is to rotate the logs of containers #####

DEPLOYMENT_TIME=$(date +%d-%B-%Y-%R)
DIR=$(date +%d-%B-%Y)
Docker_Log_Path="/var/lib/docker/containers"
Backup_Path="/data/Logs_Backup"
S3_BUCKET_NAME="your-s3-bucket-name"
Monthly_Backup_Path="/data/Logs_Backup/$(cal -3|awk 'NR==1{print toupper(substr($3,1,3))"-"$4}')"
CONTAINER_NAME=`docker ps | awk  '{print $NF}' | grep -v "NAMES"`

MonthDir_Creation()
        {
                if [ ! -d $Monthly_Backup_Path ]
                        then
                                echo "Creating this month Directory"
                                mkdir $Monthly_Backup_Path
                fi
        }

if [ ! -d $Backup_Path ]
        then
                echo "Creating Backup path"
                mkdir $Backup_Path
                MonthDir_Creation
        else
                MonthDir_Creation
fi

echo "Taking the backup of Docker logs"
        for logs_backup in $CONTAINER_NAME
                do
                        Container_log_path=$(docker inspect $logs_backup | grep "LogPath" | awk -F" " '{print $2}' | tr -d '" ,')
                        Container_log_dir=$(docker inspect  $logs_backup | grep "LogPath" | awk -F" " '{print $2}' | tr -d '" ,' |  awk -F"/" '{print $NF}'|sed 's/-json.log//g')
                        cd $Docker_Log_Path/$Container_log_dir
                        tar -zcvf  $Monthly_Backup_Path/Logs-Before-Deployment-$logs_backup-$DIR.tar.gz $Container_log_dir-json.log

                if [ -f $Monthly_Backup_Path/$logs_backup-$DIR.tar.gz ]
                        then
                                echo "nullyfing Docker logs"
                                echo "$Container_log_path"
                                truncate -s 0  $Container_log_path
                fi
                echo "Moving tar files to S3"
                aws s3 cp $Monthly_Backup_Path/Logs-Before-Deployment-$logs_backup-$DIR.tar.gz s3://$S3_BUCKET_NAME/                
                done
