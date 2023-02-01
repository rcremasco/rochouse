#!/bin/bash


APP="/docker"
Z2M_ROOT=$APP/z2m

DOCKERNAME="z2m"
DOCKERIMAGE="koenkk/zigbee2mqtt"
DOCKERVERSION="1.30.0"


SCRIPTPATH=$(dirname $0)
source $SCRIPTPATH/exec-common.sh

setupFolder()
{
  # Creazione directory
  if [ ! -d  $Z2M_ROOT ]; then
    mkdir -p $Z2M_ROOT
    sudo chown 1001:1001 $Z2M_ROOT
    writeLog "$Z2M_ROOT created"
  else
    writeLog "$Z2M_ROOT already present"
  fi

}


runDocker()
{


if [[ -c /dev/ttyACM0 ]]; then
  writeLog "INFO - Trovato USB ZIGBEE sul device /dev/ttyACM0"
  USBDEV="/dev/ttyACM0"
else
  writeLog "ERROR - Non ho trovato nessun ConBee"
  writeLog "ERROR - Esco dalla procedura..."
  exit
fi


  if ! isRunned ; then
    writeLog "run $DOCKERNAME docker"
    docker run -d --name=$DOCKERNAME \
        --net=host \
        -p 8088:8088 \
        --restart=unless-stopped \
        --device=$USBDEV \
        --user 1001:1001 \
        --group-add dialout \
        -v $Z2M_ROOT:/app/data\
        -e TZ=Europe/Rome \
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
