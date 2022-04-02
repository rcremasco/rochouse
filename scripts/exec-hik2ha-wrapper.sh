#!/bin/bash


APP="/docker"
DOCKERNAME="hik2ha-wrapper"
DOCKERIMAGE="hik2ha-wrapper"
DOCKERVERSION="latest"
HIK2HA_ROOT=$APP/$DOCKERNAME

SCRIPTPATH=$(dirname $0)
source $SCRIPTPATH/exec-common.sh

setupFolder()
{
  # Creazione directory
  if [ ! -d  $HIK2HA_ROOT ]; then
    sudo mkdir -p $HIK2HA_ROOT
    sudo chown -R pi:pi $HIK2HA_ROOT
    writeLog "$HIK2HA_ROOT created"
  else
    writeLog "$HIK2HA_ROOT already present"
  fi

}


runDocker()
{
  if ! isRunned ; then
    writeLog "buildind image"
    cd /home/pi/rochouse/hik2ha-wrapper
    docker build  -t hik2ha-wrapper .
    cd $SCRIPTPATH


    writeLog "run $DOCKERNAME docker"
    docker run -d --name=$DOCKERNAME \
        -u 1000:1000 \
        -p $VIP:88:88 \
        -v $HIK2HA_ROOT:/app \
        -e "TZ=Europe/Rome" \
        $DOCKERIMAGE
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
