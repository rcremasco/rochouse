#!/bin/bash


APP="/docker"
MM_ROOT="$APP/magicmirror"
MM_CONF="$MM_ROOT/config"
MM_MODULES="$MM_ROOT/modules"

DOCKERNAME="mm"
DOCKERIMAGE="bastilimbach/docker-magicmirror"
DOCKERVERSION="latest"

SCRIPTPATH=$(dirname $0)
source $SCRIPTPATH/exec-common.sh

setupFolder()
{
  # Creazione directory
  if [ ! -d  $MM_ROOT ]; then
    mkdir -p $MM_ROOT
    writeLog "$MM_ROOT created"
  else
    writeLog "$MM_ROOT already present"
  fi

  if [ ! -d  $MM_CONF ]; then
    mkdir -p $MM_CONF
    writeLog "$MM_CONF created"
  else
    writeLog "$MM_CONF already present"
  fi

  if [ ! -d  $MM_MODULES ]; then
    mkdir -p $MM_MODULES
    writeLog "$MM_MODULES created"
  else
    writeLog "$MM_MODULES already present"
  fi


}


runDocker()
{
  if ! isRunned ; then
    writeLog "run influx docker"
    docker run -d --name=$DOCKERNAME \
        --restart=always \
        -p $VIP:82:8080 \
        -v $MM_CONF:/opt/magic_mirror/config \
        -v $MM_MODULES:/opt/magic_mirror/modules \
        -v /etc/localtime:/etc/localtime:ro \
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


main "$@"

exit
