#!/bin/bash


APP="/docker"
MOSQUITTO_ROOT="$APP/mqtt"
MOSQUITTO_CONF="$MOSQUITTO_ROOT/conf"
MOSQUITTO_DATA="$MOSQUITTO_ROOT/data"
MOSQUITTO_LOG="$MOSQUITTO_ROOT/log"

DOCKERNAME="mqtt"
DOCKERIMAGE="eclipse-mosquitto"
DOCKERVERSION="1.6.8"

SCRIPTPATH=$(dirname $0)
source $SCRIPTPATH/exec-common.sh

setupFolder()
{
  # Creazione directory
  if [ ! -d  $MOSQUITTO_ROOT ]; then
    mkdir -p $MOSQUITTO_ROOT
    writeLog "$MOSQUITTO_ROOT created"
  else
    writeLog "$MOSQUITTO_ROOT already present"
  fi

  if [ ! -d  $MOSQUITTO_CONF ]; then
    mkdir -p $MOSQUITTO_CONF
    writeLog "$MOSQUITTO_CONF created"
  else
    writeLog "$MOSQUITTO_CONF already present"
  fi

  if [ ! -d  $MOSQUITTO_DATA ]; then
    mkdir -p $MOSQUITTO_DATA
    writeLog "$MOSQUITTO_DATA created"
  else
    writeLog "$MOSQUITTO_DATA already present"
  fi

  if [ ! -d  $MOSQUITTO_LOG ]; then
    mkdir -p $MOSQUITTO_LOG
    writeLog "$MOSQUITTO_LOG created"
  else
    writeLog "$MOSQUITTO_LOG already present"
  fi

  if [ ! -f $MOSQUITTO_CONF/mosquitto.conf ]; then
    cp $SCRIPTPATH/exec-mosquitto.conf $MOSQUITTO_CONF/mosquitto.conf
    writeLog "default config file create"
  else
    writeLog "Config file already present"
  fi

  sudo chown -R 1883:1883 $MOSQUITTO_ROOT

}


runDocker()
{
  if ! isRunned ; then
    writeLog "run influx docker"
    docker run -d --name=$DOCKERNAME \
        --restart=always \
        -p $VIP:1883:1883 \
        -p $VIP:9001:9001 \
        -v $MOSQUITTO_CONF:/mosquitto/config \
        -v $MOSQUITTO_DATA:/mosquitto/data \
        -v $MOSQUITTO_LOG:/mosquitto/log \
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
