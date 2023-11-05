#!/bin/bash
Year=`date "+%Y"`
Month=`date "+%B"`
DIR=`date +%H:%M:%S_%F`

echo " dump started"

pg_dumpall > /data/postgresdbbackup/DB_NAME_$DIR

echo " Postgrs Dump Completed"

echo "Archiving Backup"
cd /data/postgresdbbackup

zip -r DB_NAME_$DIR.zip DB_NAME_$DIR

rm -rf DB_NAME_$DIR
echo "Data Successfully Archived"
