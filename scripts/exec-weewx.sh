#!/bin/bash
#

APP="/docker"

DOCKERNAME="weewx"
DOCKERIMAGE="weewx"
DOCKERVERSION="latest"

WEEWX_ROOT=$APP/$DOCKERNAME

SCRIPTPATH=$(dirname $0)
source $SCRIPTPATH/exec-common.sh

setupFolder()
{
  # Creazione directory
  if [ ! -d  $WEEWX_ROOT ]; then
    sudo mkdir -p $WEEWX_ROOT
    writeLog "$WEEWX_ROOT created"
  else
    writeLog "$WEEWX_ROOT already present"
  fi

  if [ ! -d  $WEEWX_ROOT/data ]; then
    sudo mkdir -p $WEEWX_ROOT/data
    writeLog "$WEEWX_ROOT/data created"
  else
    writeLog "$WEEWX_ROOT/data already present"
  fi

  if [ ! -d  $WEEWX_ROOT/html ]; then
    sudo mkdir -p $WEEWX_ROOT/html
    writeLog "$WEEWX_ROOT/html created"
  else
    writeLog "$WEEWX_ROOT/html already present"
  fi

  sudo chown -R 421:421 $WEEWX_ROOT

}



runDocker()
{
  if ! isRunned ; then
    writeLog "run $DOCKERNAME docker"
    docker run --privileged -d --name=$DOCKERNAME \
        -v $WEEWX_ROOT/data:/data \
        -v $WEEWX_ROOT/html:/home/weewx/public_html \
        --net=host \
        -e TZ=Europe/Rome \
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

backupDB()
{

  writeLog "deleting old weewx db backup"
  sudo rm /backup/weewx.db.gz

  writeLog "backup deconz db"
  sqlite3 /docker/$DOCKERNAME/data/weewx.sdb .dump | gzip -c > /backup/weewx.db.gz
  writeLog "done"

}

restoreDB()
{

  writeLog "going to restore weewx db"

  writeLog "deleting old weewx db"
  sudo rm -f /docker/$DOCKERNAME/data/weewx.sdb 2>&1 | tee -a $LOGFILE

  writeLog "restoring weewx db"
  sudo zcat /media/pi/RHBCK/rochouse/backup/weewx.db.gz | sudo sqlite3 /docker/$DOCKERNAME/data/weewx.sdb 2>&1 | tee -a $LOGFILE

  writeLog "setting weewx db permission"
  sudo chown -R 421:421:pi /docker/$DOCKERNAME 2>&1 | tee -a $LOGFILE
  writeLog "restored"



}

main "$@"

exit
