#!/bin/bash
#

APP="/docker"

DOCKERNAME="httpd-weewx"
DOCKERIMAGE="httpd"
DOCKERVERSION="2.4"

HTTPDWEEWX_ROOT=$APP/$DOCKERNAME
HTTPDWEEWX_CONF=$HTTPDWEEWX_ROOT/conf

SCRIPTPATH=$(dirname $0)
source $SCRIPTPATH/exec-common.sh

setupFolder()
{
  # Creazione directory
  if [ ! -d  $HTTPDWEEWX_ROOT ]; then
    sudo mkdir -p $HTTPDWEEWX_ROOT
    writeLog "$HTTPDWEEWX_ROOT created"
  else
    writeLog "$HTTPDWEEWX_ROOT already present"
  fi

  if [ ! -d  $HTTPDWEEWX_CONF ]; then
    sudo mkdir -p $HTTPDWEEWX_CONF
    writeLog "$HTTPDWEEWX_CONF created"
  else
    writeLog "$HTTPDWEEWX_CONF already present"
  fi
#  sudo chown -R 421:421 $HTTPDWEEWX_ROOT

}

#temporaneo
VIP=192.168.10.4

runDocker()
{
  if ! isRunned ; then
    writeLog "run $DOCKERNAME docker"
    docker run -d --name=$DOCKERNAME \
        -v /docker/weewx/html:/usr/local/apache2/htdocs \
        -v $HTTPDWEEWX_CONF:/usr/local/apache2/conf \
        -p $VIP:8666:80 \
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
