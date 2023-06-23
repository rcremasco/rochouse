#!/bin/bash


APP="/docker"
NODERED_ROOT="$APP/nodered"

DOCKERNAME="nodered"
DOCKERIMAGE="nodered/node-red"
DOCKERVERSION="latest"


SCRIPTPATH=$(dirname $0)
source $SCRIPTPATH/exec-common.sh

setupFolder()
{
  # Creazione directory
  if [ ! -d  $NODERED_ROOT ]; then
    mkdir -p $NODERED_ROOT
    writeLog "$NODERED_ROOT created"
  else
    writeLog "$NODERED_ROOT already present"
  fi

  cat << EOF > /docker/nodered/addon.sh
cd /data
npm install node-red-contrib-actionflows \
    node-red-contrib-home-assistant-websocket \
    node-red-contrib-stoptimer \
    node-red-contrib-time-range-switch \
    node-red-contrib-timecheck \
    node-red-dashboard \
    node-red-contrib-moment \
    node-red-node-email \
    node-red-contrib-telegrambot \
    node-red-contrib-alexa-remote2 \
    node-red-contrib-loop-processing \
    node-red-contrib-deconz \
    node-red-contrib-influxdb \
    node-red-node-timeswitch
EOF
  chmod +x /docker/nodered/addon.sh

  sudo chown -R $USER:$USER $NODERED_ROOT

}


runDocker()
{
  if ! isRunned ; then
    writeLog "run $DOCKERNAME docker"
    docker run -d --name=$DOCKERNAME \
        -p $VIP:1880:1880 \
        -p $VIP:3456:3456 \
        -u 1000:1000 \
        -v $NODERED_ROOT:/data \
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
