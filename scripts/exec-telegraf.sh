#!/bin/bash


APP="/docker"

DOCKERNAME="telegraf"
DOCKERIMAGE="telegraf"
DOCKERVERSION="latest"

TELEGRAF_ROOT=$APP/$DOCKERNAME

SCRIPTPATH=$(dirname $0)
source $SCRIPTPATH/exec-common.sh

setupFolder()
{
  # Creazione directory
  if [ ! -d  $TELEGRAF_ROOT ]; then
    mkdir -p $TELEGRAF_ROOT
    writeLog "$TELEGRAF_ROOT created"
  else
    writeLog "$TELEGRAF_ROOT already present"
  fi

}


runDocker()
{
  if ! isRunned ; then
    writeLog "run $DOCKERNAME docker"
    docker run -d --name=$DOCKERNAME \
        -v $TELEGRAF_ROOT/telegraf.conf:/etc/telegraf/telegraf.conf:ro \
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
