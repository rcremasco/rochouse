#!/bin/bash


APP="/docker"
HA_ROOT="$APP/homeassistant"

DOCKERNAME="ha"
DOCKERIMAGE=" homeassistant/raspberrypi3-homeassistant"
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


main "$@"

exit
