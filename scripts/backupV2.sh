#!/bin/bash

writeLog()
{

    echo "$(date +"%Y/%m/%d %H:%M:%S") - $1"
    echo "$(date +"%Y/%m/%d %H:%M:%S") - $1" >> /tmp/backup.log

}


localBackup()
{

writeLog "saving to USB key /docker ..."
sudo rsync -avrWS --exclude '/docker/influxdb/data/' --exclude '*.db' --inplace /docker /media/pi/RHBCK/rochouse

if [ ! -d /media/pi/RHBCK/rochouse/images ]; then
  writeLog "Creating docker/images on USB key"
  sudo mkdir -p /media/pi/RHBCK/rochouse/images
  sudo chown -R pi:pi /media/pi/RHBCK/rochouse
fi

writeLog "saving to USB key home-assistant image"
docker save --output=/media/pi/RHBCK/rochouse/images/ha.tar homeassistant/raspberrypi3-homeassistant

writeLog "saving to USB key deconz image"
docker save --output=/media/pi/RHBCK/rochouse/images/deconz.tar deconzcommunity/deconz


writeLog "saving to USB key chain2 image"
docker save --output=/media/pi/RHBCK/rochouse/images/chain2.tar chain2

writeLog "saving to USB key hik2ha-wrapper image"
docker save --output=/media/pi/RHBCK/rochouse/images/hik2ha-wrapper.tar hik2ha-wrapper

writeLog "saving to USB key docker-magicmirror image"
docker save --output=/media/pi/RHBCK/rochouse/images/mm.tar bastilimbach/docker-magicmirror

writeLog "saving to USB key influxdb image"
docker save --output=/media/pi/RHBCK/rochouse/images/influxdb.tar influxdb:1.8

writeLog "saving to USB key grafana image"
docker save --output=/media/pi/RHBCK/rochouse/images/grafana.tar grafana/grafana 

writeLog "saving to USB key telegraf image"
docker save --output=/media/pi/RHBCK/rochouse/images/telegraf.tar telegraf

writeLog "saving to USB key chronograf image"
docker save --output=/media/pi/RHBCK/rochouse/images/chronograf.tar chronograf

writeLog "saving to USB key node red-image"
docker save --output=/media/pi/RHBCK/rochouse/images/node-red.tar nodered/nodered

writeLog "saving to USB key mosquito image"
docker save --output=/media/pi/RHBCK/rochouse/images/mqtt.tar eclipse-mosquitto

if [ ! -d /media/pi/RHBCK/rochouse/backup ]; then
  writeLog "Creating docker/backup on USB key"
  sudo mkdir -p /media/pi/RHBCK/rochouse/backup
  sudo chown -R pi:pi /media/pi/RHBCK/rochouse/backup
fi


writeLog "Exporting influxDb data"
sudo rm /backup/influx.bck/ha/*
sudo rm /backup/influx.bck/telegraf/*
writeLog "exporting ha influx db"
docker exec -i influxdb influxd  backup -portable -database ha -host 127.0.0.1:8088 /backup/influx.bck/ha
writeLog "exporting telegraf influx db"
docker exec -i influxdb influxd  backup -portable -database telegraf -host 127.0.0.1:8088 /backup/influx.bck/telegraf
writeLog "Exporting to USB key influxDb data"
sudo rsync -avrWS --inplace /backup/influx.bck /media/pi/RHBCK/rochouse/backup

writeLog "Exporting to USB key home-assistant db"
sqlite3 /docker/homeassistant/home-assistant_v2.db .dump | gzip -c > /media/pi/RHBCK/rochouse/backup/ha.db.gz

writeLog "Exporting to USB key deconz db"
sqlite3 /docker/deconz/zll.db .dump | gzip -c > /media/pi/RHBCK/rochouse/backup/zll.db.gz

writeLog "Exporting to USB key grafana db"
sqlite3 /docker/grafana/grafana.db .dump | gzip -c > /media/pi/RHBCK/rochouse/backup/grafana.db.gz

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
rclone sync /backup/ GDRIVE:raspi/backup/  --stats-one-line-date -P --stats 10m

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
