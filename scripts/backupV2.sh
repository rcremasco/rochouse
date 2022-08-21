#!/bin/bash

SCRIPTPATH=$(dirname $0)
LOGFILE="/tmp/backup.log"


writeLog()
{

    echo "$(date +"%Y/%m/%d %H:%M:%S") - $1"
    echo "$(date +"%Y/%m/%d %H:%M:%S") - $1" >> $LOGFILE

}


localBackup()
{

  writeLog "saving home-assistant image"
  $SCRIPTPATH/exec-homeassistant.sh save 2>&1 | tee -a $LOGFILE

  writeLog "saving deconz image"
  $SCRIPTPATH/exec-deconz.sh save 2>&1 | tee -a $LOGFILE

  writeLog "saving chain2 image"
  $SCRIPTPATH/exec-chain2.sh save 2>&1 | tee -a $LOGFILE
 
  writeLog "saving hik2ha-wrapper image"
  $SCRIPTPATH/exec-hik2ha-wrapper.sh save 2>&1 | tee -a $LOGFILE
 
  writeLog "saving docker-magicmirror image"
  $SCRIPTPATH/exec-magicmirror.sh save 2>&1 | tee -a $LOGFILE

  writeLog "saving influxdb image"
  $SCRIPTPATH/exec-influx.sh save 2>&1 | tee -a $LOGFILE

  writeLog "saving grafana image"
  $SCRIPTPATH/exec-grafana.sh save 2>&1 | tee -a $LOGFILE

  writeLog "saving telegraf image"
  $SCRIPTPATH/exec-telegraf.sh save 2>&1 | tee -a $LOGFILE

  writeLog "saving chronograf image"
  $SCRIPTPATH/exec-chronograf.sh save 2>&1 | tee -a $LOGFILE

  writeLog "saving node red-image"
  $SCRIPTPATH/exec-nodered.sh save 2>&1 | tee -a $LOGFILE

  writeLog "saving mosquito image"
  $SCRIPTPATH/exec-magicmirror.sh save 2>&1 | tee -a $LOGFILE

  writeLog "saving weewx image"
  $SCRIPTPATH/exec-weewx.sh save 2>&1 | tee -a $LOGFILE

  writeLog "saving httpd-weewx image"
  $SCRIPTPATH/exec-httpd-weewx.sh save 2>&1 | tee -a $LOGFILE

  writeLog "Exporting influxDb data"
  $SCRIPTPATH/exec-influx.sh backupdb 2>&1 | tee -a $LOGFILE

  writeLog "Exporting home-assistant db"
  $SCRIPTPATH/exec-homeassistant.sh backupdb 2>&1 | tee -a $LOGFILE

  writeLog "Exporting deconz db"
  $SCRIPTPATH/exec-deconz.sh backupdb 2>&1 | tee -a $LOGFILE

  writeLog "Exporting grafana db"
  $SCRIPTPATH/exec-grafana.sh backupdb 2>&1 | tee -a $LOGFILE

  writeLog "Exporting weewx db"
  $SCRIPTPATH/exec-weewx.sh backupdb 2>&1 | tee -a $LOGFILE

  writeLog "saving /docker to USB key"
  sudo rsync -avrWS --exclude '/docker/influxdb/data/' --exclude '*.db' --inplace /docker /media/pi/RHBCK/rochouse

  writeLog "saving /backup to USB key"
  sudo rsync -avrWS  --inplace /backup /media/pi/RHBCK/rochouse

  sync
  sync

}


rm -f /tmp/backup.log
writeLog "Starting..."

if [ -d /media/pi/RHBCK ]; then
  writeLog "INFO - USB Key found. Starting local backup."
  localBackup
  writeLog "INFO - End local USB backup"
fi
exit
writeLog "Saving homeassistant folder"
rclone sync /docker/homeassistant/ GDRIVE:raspi/docker/homeassistant --exclude home-assistant.log --exclude home-assistant_v2.db --stats-one-line-date -P --stats 10m

writeLog "Saving deconz folder"
rclone sync /docker/deconz/ GDRIVE:raspi/docker/deconz  --exclude zll.db  --stats-one-line-date -P --stats 10m

writeLog "Saving grafana folder"
rclone sync /docker/grafana/ GDRIVE:raspi/docker/grafana --exclude grafana.db  --stats-one-line-date -P --stats 10m

writeLog "Saving telegraf folder"
rclone sync /docker/telegraf/ GDRIVE:raspi/docker/telegraf  --stats-one-line-date -P --stats 10m

writeLog "Saving chronograf folder"
rclone sync /docker/chronograf/ GDRIVE:raspi/docker/chronograf  --stats-one-line-date -P --stats 10m

writeLog "Saving influxDb config folder"
rclone sync /docker/influxdb/etc/influxdb.conf GDRIVE:raspi/docker/influxdb/etc/influxdb/  --exclude data  --stats-one-line-date -P --stats 10m

writeLog "Saving mqtt config folder"
rclone sync /docker/mqtt/conf/ GDRIVE:raspi/docker/mqtt/conf/  --stats-one-line-date -P --stats 10m

writeLog "Saving nodered config folder"
rclone sync /docker/nodered/ GDRIVE:raspi/docker/nodered --stats-one-line-date -P --stats 10m

writeLog "Exporting influxDb data"
rm /backup/influx.bck/ha/*
rm /backup/influx.bck/telegraf/*
docker exec -i influxdb influxd  backup -portable -database ha -host 127.0.0.1:8088 /backup/influx.bck/ha
docker exec -i influxdb influxd  backup -portable -database telegraf -host 127.0.0.1:8088 /backup/influx.bck/telegraf

writeLog "Exporting home-assistant db"
sqlite3 /docker/homeassistant/home-assistant_v2.db .dump | gzip -c > /backup/ha.db.gz

writeLog "Exporting deconz db"
sqlite3 /docker/deconz/zll.db .dump | gzip -c > /backup/zll.db.gz

writeLog "Exporting grafana db"
sqlite3 /docker/grafana/grafana.db .dump | gzip -c > /backup/grafana.db.gz

writeLog "Saving exported data"
rclone delete GDRIVE:raspi/backup/influx.bck/ha  --stats-one-line-date -P --stats 10m
rclone delete GDRIVE:raspi/backup/influx.bck/telegraf  --stats-one-line-date -P --stats 10m
rclone sync /backup/ GDRIVE:raspi/backup/  --exclude images --stats-one-line-date -P --stats 10m

writeLog "Saving openvpn config"
rclone sync /etc/openvpn/ GDRIVE:raspi/etc/openvpn  --stats-one-line-date -P --stats 10m

writeLog "Saving samba config"
rclone sync /etc/samba/ GDRIVE:raspi/etc/samba  --stats-one-line-date -P --stats 10m

writeLog "Saving /home/pi"
rclone sync /home/pi/  GDRIVE:raspi/home/pi --exclude=chromium/** --exclude=.cache/** --exclude=./config/** --exclude=./local/** --exclude=./vscode/**  --exclude=./npm/** --exclude=temp/** --exclude=tensorflow/** --stats-one-line-date -P --stats 10m

writeLog "Saving backup.sh script"
rclone sync /root/backup.sh GDRIVE:raspi/root/  --stats-one-line-date -P --stats 10m

writeLog "Saving /root"
rclone sync /root/ GDRIVE:raspi/root/ --exclude=chromium/** --exclude=.cache/** --exclude .npm\**  --stats-one-line-date -P --stats 10m

writeLog "Completed"
