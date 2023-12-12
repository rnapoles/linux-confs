#!/bin/bash
# Add the backup dir location, MySQL root password, MySQL and mysqldump location
#0 * * * * /root/scripts/mysql-backup.sh  >/dev/null 2>&1

DATE=$(date +%Y/%m/%d/%H/%M)
BACKUP_DIR="/opt/backup/mysql"
MYSQL_USER="root"
MYSQL_PASSWORD="*****"
MYSQL=/usr/bin/mysql
MYSQLDUMP=/usr/bin/mysqldump 
 
# To create a new directory in the backup directory location based on the date
mkdir -p $BACKUP_DIR/$DATE
 
# To get a list of databases
databases=`$MYSQL -u$MYSQL_USER -p$MYSQL_PASSWORD -e "SHOW DATABASES;" | grep -Ev "(Database|information_schema)"`
 
# To dump each database in a separate file
for db in $databases; do
echo $db
$MYSQLDUMP --force --opt --skip-lock-tables --user=$MYSQL_USER -p$MYSQL_PASSWORD --databases $db | gzip > "$BACKUP_DIR/$DATE/$db.sql.gz"
done
 
# Delete the files older than 10 days
find $BACKUP_DIR/* -mtime +10 -exec rm {} \;