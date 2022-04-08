#!/bin/bash


APP="/docker"

DOCKERNAME="weewx"
DOCKERIMAGE="felddy/weewx"
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

  if [ ! -d  $WEEWX_ROOT/log ]; then
    sudo mkdir -p $WEEWX_ROOT/log
    writeLog "$WEEWX_ROOT/log created"
  else
    writeLog "$WEEWX_ROOT/log already present"
  fi

  sudo chown -R pi:pi $WEEWX_ROOT

}


runDocker()
{
  if ! isRunned ; then
    writeLog "run $DOCKERNAME docker"
    docker run -d --name=$DOCKERNAME \
        -v $WEEWX_ROOT/data:/data \
        -v $WEEWX_ROOT/log:/var/log \
        -v $WEEWX_ROOT/html:/home/weewx/public_html \
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


main "$@"

exit
