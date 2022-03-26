#!/bin/bash


APP="/docker"
DOCKERNAME="chronograf"
DOCKERIMAGE="chronograf"
DOCKERVERSION="latest"
CHRONOGRAF_ROOT=$APP/$DOCKERNAME

SCRIPTPATH=$(dirname $0)
source $SCRIPTPATH/exec-common.sh

setupFolder()
{
  # Creazione directory
  if [ ! -d  $CHRONOGRAF_ROOT ]; then
    mkdir -p $CHRONOGRAF_ROOT
    writeLog "$CHRONOGRAF_ROOT created"
  else
    writeLog "$CHRONOGRAF_ROOT already present"
  fi

}


runDocker()
{
  if ! isRunned ; then
    writeLog "run $DOCKERNAME docker"
    docker run -d --name=$DOCKERNAME \
        -v $CHRONOGRAF_ROOT:/var/lib/chronograf \
        -p $VIP:8888:8888 \
        --restart=always \
        $DOCKERIMAGE:$DOCKERVERSION \
        --influxdb-url=http://$VIP:8086

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
