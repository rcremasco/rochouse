#!/bin/bash
#
#
#

SCRIPTPATH=$(dirname $0)
LOGFILE="/tmp/slaveStart.log"

writeLog()
{
  echo "$(date +%Y-%m-%d_%H:%M:%S) $1"
  echo "$(date +%Y-%m-%d_%H:%M:%S) $1" >>/tmp/slaveStart.log
}

checkPrerequisiteOK()
{

  check=0
  if ! which docker &> /dev/null; then
    writeLog "ERROR - Docker non ancora installato. Installarlo..."
    ((check=check+1))
  else
    writeLog "INFO - Docker presente."
  fi

  if ! which rclone &> /dev/null; then
    writeLog "ERROR - rclone non ancora installato. Installarlo..."
    ((check=check+1))
  else
    writeLog "INFO - rclone presente."
  fi


  writeLog "INFO - Verifico che /docker esista"
  if [[ -d /docker ]]
  then
    writeLog "INFO - directory /docker presente, confermo permessi."
    sudo chown root:docker /docker 2>&1 | tee -a $LOGFILE
  else
    writeLog "INFO - directory /docker assente, viene creata"
    sudo mkdir /docker 2>&1 | tee -a $LOGFILE
    sudo chown root:docker /docker 2>&1 | tee -a $LOGFILE
  fi

  if [ $check -gt 0 ]; then
    return 0
  else
    return 1
  fi

}

localRestore()
{

  writeLog "INFO - riprinstino della /docker"
  sudo rsync -avrWS --inplace /media/pi/RHBCK/rochouse/docker / 2>&1 | tee -a $LOGFILE
  sudo chown -R pi:pi /docker 2>&1 | tee -a $LOGFILE

  docker system prune -a -f 2>&1 | tee -a $LOGFILE

  writeLog "INFO - riprinstino della /backup"
  sudo rsync -avrWS --inplace /media/pi/RHBCK/rochouse/backup / 2>&1 | tee -a $LOGFILE
  sudo chown -R pi:pi /backup 2>&1 | tee -a $LOGFILE

  writeLog "INFO - ripristino immagine docker chain2"
  $SCRIPTPATH/exec-chain2.sh stop remove removeImage load 2>&1 | tee -a $LOGFILE

  writeLog "INFO - ripristino immagine docker chronograf"
  $SCRIPTPATH/exec-chronograf.sh stop remove removeImage load 2>&1 | tee -a $LOGFILE

  writeLog "INFO - ripristino immagine docker deconz"
  $SCRIPTPATH/exec-deconz.sh stop remove removeImage load 2>&1 | tee -a $LOGFILE

  writeLog "INFO - ripristino immagine docker docker-magicmirror"
  $SCRIPTPATH/exec-magicmirror.sh stop remove removeImage load 2>&1 | tee -a $LOGFILE

  writeLog "INFO - ripristino immagine docker grafana"
  $SCRIPTPATH/exec-grafana.sh stop remove removeImage load 2>&1 | tee -a $LOGFILE

  writeLog "INFO - ripristino immagine docker hik2ha-wrapper"
  $SCRIPTPATH/exec-hik2ha-wrapper.sh stop remove removeImage load 2>&1 | tee -a $LOGFILE

  writeLog "INFO - ripristino immagine docker home-assistant"
  $SCRIPTPATH/exec-homeassistant.sh stop remove removeImage load 2>&1 | tee -a $LOGFILE

  writeLog "INFO - ripristino immagine docker influxdb"
  $SCRIPTPATH/exec-influxdb.sh stop remove removeImage load 2>&1 | tee -a $LOGFILE

  writeLog "INFO - ripristino immagine docker mosquito"
  $SCRIPTPATH/exec-magicmirror.sh stop remove removeImage load 2>&1 | tee -a $LOGFILE

  writeLog "INFO - ripristino immagine docker node-red"
  $SCRIPTPATH/exec-nodered.sh stop remove removeImage load 2>&1 | tee -a $LOGFILE

  writeLog "INFO - ripristino immagine docker telegraf"
  $SCRIPTPATH/exec-telegraf.sh stop remove removeImage load 2>&1 | tee -a $LOGFILE

  docker images 2>&1 | tee -a $LOGFILE

  writeLog "INFO - Ripristino database deconz"
  $SCRIPTPATH/exec-deconz.sh restoredb 2>&1 | tee -a $LOGFILE

  writeLog "INFO - Restoring home assistant db"
  $SCRIPTPATH/exec-homeassistant.sh restoredb 2>&1 | tee -a $LOGFILE
 
  writeLog "INFO - Restoring grafana db"
  $SCRIPTPATH/exec-grafana.sh restoredb 2>&1 | tee -a $LOGFILE
 
}

writeLog "INFO - Processo di boot dello SLAVE..."

writeLog "INFO - Processo attivo come $(whoami)"

writeLog "INFO - Controllo prerequisiti"
if checkPrerequisiteOK; then
  writeLog "ERROR - Prerequisiti mancanti per proseguire"
  exit
else
  writeLog "INFO - Prerequisiti OK"
fi


writeLog "INFO - Installo prerequisiti"
#chown root:docker /docker
#apt-get -y install sqlite

sleep 5


# if [[ "$(gpio read 2)" -eq "0" ]]; then
#   writeLog "INFO - Switch di start slave disabilitato"
#   writeLog "INFO - Esco dalla procedura"
#   exit 1
# else
#   writeLog "INFO - Switch di start slave abilitato, procedo"
# fi

writeLog "INFO - Controllo connettività WiFi."

maxRetry=20;
i=0;
netOk=0;
while [ ! $netOk -eq 1 ];
do
  if ping -c 1 192.168.10.1 > /dev/null; then
    writeLog "INFO - OK raggiungo il default gateway, procedo...."
    netOk=1;
  else
    writeLog "WARNING - Non raggiungo il default gateway "
  fi

  i=$(( $i+1 ))

  if [ $i -ge $maxRetry ]; then
    writeLog "ERROR - Scaduto tempo di attesa default gateway"
    writeLog "ERROR - Esco dalla procedura..."
    exit 1
  fi

done

i=0;
netOk=0;
while [ ! $netOk -eq 1 ];
do
  if ping -c 1 8.8.8.8 > /dev/null; then
    writeLog "INFO - Connessione Internet OK, procedo..."
    netOk=1;
  else
    writeLog "WARNING - Connessione internet assente"
  fi

  i=$(( $i+1 ))

  if [ $i -ge $maxRetry ]; then
    writeLog "ERROR - Scaduto tempo di attesa internet"
    writeLog "ERROR - Esco dalla procedura..."
    exit 1
  fi

done

if [[ -c /dev/ttyUSB0 ]]; then
  writeLog "INFO - Trovato ConBee sul device /dev/ttyUSB0"
  CONDEV="/dev/ttyUSB0"
elif [[ -c /dev/ttyACM0 ]]; then
  writeLog "INFO - Trovato ConBee II sul device /dev/ttyACM0"
  CONDEV="/dev/ttyACM0"
else
  writeLog "ERROR - Non ho trovato nessun ConBee"
  writeLog "ERROR - Esco dalla procedura..."
#  exit
fi


writeLog "INFO - Controllo se il Master è attivo..."
if ping -c 1 192.168.10.4 > /dev/null; then
  writeLog "WARNING - il Master è attivo"
  writeLog "WARNING - Fermo i servizi sul Master per evitare conflitti"
  writeLog "INFO - Fermo home-assistant"
#  ssh pi@192.168.10.4 'docker stop home-assistant'
  writeLog "INFO - Fermo deconz"
#  ssh pi@192.168.10.4 'docker stop deconz'
else
  writeLog "INFO - Il master non risponde, lo considero morto e faccio partire i processi su Slave"
fi


if [ -d /media/pi/RHBCK ]; then
  writeLog "INFO - Trovata chiavetta con i backup, rispristino da USB key"
  localRestore
fi

exit

writeLog "INFO - Ripristino i dati in /backup"
[ ! -d /backup/ ] && mkdir -p /backup
rclone sync GDRIVE:raspi/backup/ /backup/
writeLog "INFO - Rispristino OK"

writeLog "INFO - Fermo deconz"
#su -c "docker stop deconz" pi
writeLog "INFO - rimuovo precedente deconz"
#su -c "docker rm deconz" pi
writeLog "INFO - Aggiorno deconz"
#su -c "docker pull marthoc/deconz" pi
writeLog "INFO - deconz aggiornato"

writeLog "INFO - Ripristino i dati di deconz"
rclone sync GDRIVE:raspi/docker/deconz /docker/deconz/
writeLog "INFO - Ripristino database deconz"
rm -f /docker/deconz/zll.db
zcat /backup/zll.db.gz | sqlite3 /docker/deconz/zll.db
chown -R pi:pi /docker/deconz


writeLog "INFO - Attivazione di deconz sul device $CONDEV"
#su -c "docker run -d --name=deconz --net=host --restart=always -v /docker/deconz:/root/.local/share/dresden-elektronik/deCONZ --device=$CONDEV -e DECONZ_VNC_MODE=0 -e DECONZ_VNC_PORT=5900  -e DECONZ_VNC_PASSWORD=changeme  marthoc/deconz" pi
#su -c "docker update  --restart=unless-stopped deconz" pi
writeLog "INFO - deconz Attivato"


writeLog "INFO - Fermo home-assistant"
#su -c "docker stop home-assistant" pi
writeLog "INFO - Rimuovo precedente home-assistant"
#su -c "docker rm home-assistant" pi
writeLog "INFO - Aggiorno home-assistant"
#su -c "docker pull homeassistant/raspberrypi3-homeassistant" pi
#su -c "docker update  --restart=unless-stopped home-assistant" pi
writeLog "INFO - home-assistant aggiornato"

writeLog "INFO - Ripristino file di home-assistant"
rclone sync GDRIVE:raspi/docker/homeassistant /docker/homeassistant
writeLog "Restoring home assistant db"
rm -f /docker/homeassistant/home-assistant_v2.db
zcat /backup/ha.db.gz | sqlite3 /docker/homeassistant/home-assistant_v2.db
writeLog "INFO - Aggancio deconz locale"
sed -i 's/192\.168\.10\.4/192\.168\.10\.5/g' /docker/homeassistant/.storage/core.config_entries
chown -R pi:pi /docker/homeassistant

writeLog "INFO - Attivazione di home assistant"
#su -c "docker run -d --name="home-assistant" -v /docker/homeassistant:/config -v /etc/localtime:/etc/localtime:ro --net=host homeassistant/raspberrypi3-homeassistant" pi
writeLog "INFO - home assistant attivato"


#writeLog "Stopping influxdb"
#systemctl stop influxdb
#writeLog "Getting influxdb config"
#rclone sync GDRIVE:raspi/etc/influxdb/influxdb.conf /etc/influxdb/
#writeLog "Starting influxdb"
#systemctl start influxdb


#writeLog "INFO - Fermo openvpn"
#systemctl stop openvpn@client.service
#writeLog "INFO - Ripristino configurazione openvpn"
#rclone sync GDRIVE:raspi/etc/openvpn /etc/openvpn
#writeLog "INFO - Attivazione openvpn"
#systemctl start openvpn@client.service
#writeLog "INFO - openvpn attivata"

writeLog "INFO - Processo attivazione Slave completata"

