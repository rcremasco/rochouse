#!/bin/bash


APP="/docker"
HA_ROOT="$APP/homeassistant"

DOCKERNAME="homeass"

if [ $(uname -a | grep aarch64 | wc -l) -eq 1 ]; then
  DOCKERIMAGE="homeassistant/raspberrypi3-homeassistant"
else
  DOCKERIMAGE="ghcr.io/home-assistant/home-assistant"
fi

DOCKERVERSION="stable"


SCRIPTPATH=$(dirname $0)
source $SCRIPTPATH/exec-common.sh

setupFolder()
{
  # Creazione directory
  if [ ! -d  $HA_ROOT ]; then
    mkdir -p $HA_ROOT
    writeLog "$HA_ROOT created"
  else
    writeLog "$HA_ROOT already present"
  fi

}


runDocker()
{
  if ! isRunned ; then
    writeLog "run $DOCKERNAME docker"
    docker run -d --name=$DOCKERNAME \
        --net=host \
        -v $HA_ROOT:/config \
        -v /etc/localtime:/etc/localtime:ro \
        --privileged \
        -e "TZ=Europe/Rome" \
        --restart=always \
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

  writeLog "going to restore homeassistant db"

  writeLog "deleting old ha db"
  sudo rm -f /docker/homeassistant/home-assistant_v2.db 2>&1 | tee -a $LOGFILE

  writeLog "restoring ha db"
  sudo zcat /backup/ha.db.gz | sudo sqlite3 /docker/homeassistant/home-assistant_v2.db 2>&1 | tee -a $LOGFILE

  writeLog "setting ha db permission"
  sudo chown -R pi:pi /docker/homeassistant/home-assistant_v2.db 2>&1 | tee -a $LOGFILE
  writeLog "restored"

}

backupDB()
{

  writeLog "deleting old ha db backup"
  sudo rm /backup/ha.db.gz

  writeLog "backup ha db"
  sqlite3 /docker/homeassistant/home-assistant_v2.db .dump | gzip -c > /backup/ha.db.gz
  writeLog "done"

}


main "$@"

exit
