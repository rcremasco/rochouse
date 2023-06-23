#!/bin/bash


APP="/docker"
DECONZ_ROOT=$APP/deconz

DOCKERNAME="deconz"
DOCKERIMAGE="deconzcommunity/deconz"
DOCKERVERSION="stable"


SCRIPTPATH=$(dirname $0)
source $SCRIPTPATH/exec-common.sh

setupFolder()
{
  # Creazione directory
  if [ ! -d  $DECONZ_ROOT ]; then
    mkdir -p $DECONZ_ROOT
    writeLog "$DECONZ_ROOT created"
  else
    writeLog "$DECONZ_ROOT already present"
  fi

}


runDocker()
{


if [[ -c /dev/ttyUSB0 ]]; then
  writeLog "INFO - Trovato ConBee sul device /dev/ttyUSB0"
  CONDEV="/dev/ttyUSB0"
elif [[ -c /dev/ttyACM0 ]]; then
  writeLog "INFO - Trovato ConBee II sul device /dev/ttyACM0"
  CONDEV="/dev/ttyACM0"
else
  writeLog "ERROR - Non ho trovato nessun ConBee"
  writeLog "ERROR - Esco dalla procedura..."
  exit
fi


  if ! isRunned ; then
    writeLog "run $DOCKERNAME docker"
    docker run -d --name=$DOCKERNAME \
        --net=host \
        --restart=always \
        --device=$CONDEV \
        --privileged \
        -v /docker/deconz:/opt/deCONZ\
        -e DECONZ_DEVICE=$DEV \
        -e TZ=Europe/Rome \
        -e DECONZ_VNC_MODE=1 \
        -e DECONZ_VNC_PORT=5901 \
        -e DECONZ_WEB_PORT=81 \
        -e DECONZ_VNC_PASSWORD=ciao \
        -e DEBUG_INFO=1  \
        -e DEBUG_APS=0  \
        -e DEBUG_ZCL=0  \
        -e DEBUG_DDF=0  \
        -e DEBUG_DEV=1  \
        -e DEBUG_OTA=0  \
        -e DEBUG_ERROR=1  \
        -e DEBUG_HTTP=0  \
        $DOCKERIMAGE:$DOCKERVERSION

    writeLog "runed"

    setupDocker
  else
    writeLog "$DOCKERNAME already running"
  fi

}

setupDocker()
{
  writeLog "setting docker"
  docker update  --restart=unless-stopped $DOCKERNAME
}

restoreDB()
{

  writeLog "going to restore deconz db"

  writeLog "deleting old deconz db"
  sudo rm -f /docker/deconz/zll.db 2>&1 | tee -a $LOGFILE

  writeLog "restoring deconz db"
  sudo zcat /backup/zll.db.gz | sudo sqlite3 /docker/deconz/zll.db 2>&1 | tee -a $LOGFILE

  writeLog "setting deconz db permission"
  sudo chown -R $USER:$USER /docker/deconz 2>&1 | tee -a $LOGFILE
  writeLog "restored"



}

backupDB()
{

  writeLog "deleting old deconz db backup"
  sudo rm /backup/zll.db.gz

  writeLog "backup deconz db"
  sqlite3 /docker/deconz/zll.db .dump | gzip -c > /backup/zll.db.gz
  writeLog "done"

}


main "$@"

exit
