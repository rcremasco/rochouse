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
    mkdir -p $WEEWX_ROOT
    chown -R 1111:1111 $WEEWX_ROOT
    writeLog "$WEEWX_ROOT created"
  else
    writeLog "$WEEWX_ROOT already present"
  fi

}


runDocker()
{
  if ! isRunned ; then
    writeLog "run $DOCKERNAME docker"
    docker run -d --name=$DOCKERNAME \
        -v $WEEWX_ROOT/data:/data \
        -e TIMEZONE=Europe/Rome \
        -e WEEWX_UID=1111 \
        -e WEEWX_GID=1111 \
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
