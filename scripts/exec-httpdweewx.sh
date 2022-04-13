#!/bin/bash
#

APP="/docker"

DOCKERNAME="httpd-weewx"
DOCKERIMAGE="httpd"
DOCKERVERSION="2.4"

HTTPDW_ROOT=$APP/$DOCKERNAME

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

#  sudo chown -R 421:421 $WEEWX_ROOT

}

#temporaneo
VIP=192.168.10.4

runDocker()
{
  if ! isRunned ; then
    writeLog "run $DOCKERNAME docker"
    docker run -d --name=$DOCKERNAME \
        -v /docker/weewx/html:/usr/local/apache2/htdocs \
        -p $VIP:8666:8666 \
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
