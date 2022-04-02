#!/bin/bash

APP="/docker"
GRAFANA_ROOT="$APP/grafana"
GRAFANA_CONF="$APP/grafana/etc/grafana.ini"
DOCKERNAME="grafana"
DOCKERIMAGE="grafana/grafana"
DOCKERVERSION="latest"

SCRIPTPATH=$(dirname $0)
source $SCRIPTPATH/exec-common.sh

setupFolder()
{
  # Creazione directory
  if [ ! -d  $GRAFANA_ROOT ]; then
    mkdir -p $GRAFANA_ROOT
    sudo chown -R 472:0 $GRAFANA_ROOT
    writeLog "$GRAFANA_ROOT created"
  else
    sudo chown -R 472:0 $GRAFANA_ROOT
    writeLog "$GRAFANA_ROOT already present"
  fi

}


runDocker()
{
  if ! isRunned ; then
    writeLog "run influx docker"
    docker run -d --name=$DOCKERNAME \
        --restart=always \
        -p $VIP:3000:3000 \
        -v $GRAFANA_ROOT:/var/lib/grafana \
        -v $GRAFANA_CONF:/etc/grafana/grafana.ini \
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

  writeLog "going to restore grafana db"

  writeLog "deleting old grafana db"
  sudo rm -f /docker/grafana/grafana.db 2>&1 | tee -a $LOGFILE

  writeLog "restoring grafana db"
  sudo zcat /backup/grafana.db.gz | sudo sqlite3 /docker/grafana/grafana.db 2>&1 | tee -a $LOGFILE

  writeLog "setting grafana db permission"
  sudo chown -R pi:pi /docker/homeassistant/home-assistant_v2.db 2>&1 | tee -a $LOGFILE
  writeLog "restored"

}

backupDB()
{

  writeLog "deleting old grafana db backup"
  sudo rm backup/grafana.db.gz

  writeLog "backup granafa db"
  sqlite3 /docker/grafana/grafana.db .dump | gzip -c > /backup/grafana.db.gz
  writeLog "done"

}

main "$@"

exit
