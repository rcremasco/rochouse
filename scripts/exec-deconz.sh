#!/bin/bash


APP="/docker"
DECONZ_ROOT=$APP/deconz

DOCKERNAME="deconz"
DOCKERIMAGE="deconzcommunity/deconz"
DOCKERVERSION="latest"


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
        -v /docker/deconz:/opt/deCONZ\
        -e DECONZ_DEVICE=$DEV \
        -e TZ=Europe/Rome \
        -e DECONZ_VNC_MODE=1 \
        -e DECONZ_VNC_PORT=5901 \
        -e DECONZ_WEB_PORT=81 \
        $DOCKERIMAGE:DOCKERVERSION

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
