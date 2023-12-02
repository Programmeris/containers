#!/bin/sh

echo "PGDATABASE: $PGDATABASE" && [ -z "$PGDATABASE" ] && echo "... variable not set" && exit 1
echo "PGHOST: $PGHOST" && [ -z "$PGHOST" ] && echo "... variable not set" && exit 1
echo "PGUSER: $PGUSER" && [ -z "$PGUSER" ] && echo "... variable not set" && exit 1
echo "PGPASSWORD: $(echo "${PGPASSWORD//?/*}")" && [ -z "$PGPASSWORD" ] && echo "... variable not set" && exit 1
echo "EXPIRE_DAYS: $EXPIRE_DAYS" && [ -z "$EXPIRE_DAYS" ] && echo "... variable not set" && exit 1
! [[ $EXPIRE_DAYS =~ ^[0-9]*d$ ]] && echo "EXPIRE_DAYS has bad format. Example: 30d" && exit 1
echo "S3_URL: $S3_URL" && [ -z "$S3_URL" ] && echo "... variable not set" && exit 1
echo "S3_ACCESS_KEY: $(echo "${S3_ACCESS_KEY//?/*}")" && [ -z "$S3_ACCESS_KEY" ] && echo "... variable not set" && exit 1
echo "S3_SECRET_KEY: $(echo "${S3_SECRET_KEY//?/*}")" && [ -z "$S3_SECRET_KEY" ] && echo "... variable not set" && exit 1

echo "Adding $S3_URL as backup_storage..."
mc alias set backup_storage $S3_URL $S3_ACCESS_KEY $S3_SECRET_KEY
echo "Starting backup $PGDATABASE:"
mc mb --ignore-existing backup_storage/$PGHOST-backup

pg_dump -Fc $DUMP_OPTIONS | mc pipe -q backup_storage/$PGHOST-backup/$PGDATABASE-$(date '+%Y-%m-%d-%H-%M-%S').dump
echo -e "\nBackup finished."

echo -e "Existing backups:"
mc ls backup_storage/$PGHOST-backup/
echo -e "\nRemoving backups older than $EXPIRE_DAYS days:"
mc find backup_storage/$PGHOST-backup --older-than $EXPIRE_DAYS --exec "mc rm {}"
echo -e "\nDone"
