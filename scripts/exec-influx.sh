#!/bin/bash
# per generare il file influxdb.conf da mettere in /docker/influxdb/etc
# prima di lanciare il docker
# docker run --rm influxdb influxd config > influxdb.conf
#
# creato lo user admin
#pi@raspberrypi:~ $ docker exec -it influxdb bash
#root@397b197568e4:/# influx
#Connected to http://localhost:8086 version 1.7.9
#InfluxDB shell version: 1.7.9
#> CREATE USER admin WITH PASSWORD 'Salm0ne' WITH ALL PRIVILEGES
##>


#VERSION="1.6.4-alpine"
APP="/docker"
INFLUX_ROOT="$APP/influxdb"
INFLUX_DATA="$INFLUX_ROOT/data"
INFLUX_CONF="$INFLUX_ROOT/etc"
INFLUX_TYPESDB="$INFLUX_ROOT/types-db"
DOCKERNAME="influxdb"
DOCKERIMAGE="influxdb"
DOCKERVERSION="1.8"

SCRIPTPATH=$(dirname $0)
source $SCRIPTPATH/exec-common.sh

setupFolder()
{
  # Creazione directory
  if [ ! -d  $INFLUX_DATA ]; then
    mkdir -p $INFLUX_DATA
    writeLog "$INFLUX_DATA created"
  else
    writeLog "$INFLUX_DATA already present"
  fi

  if [ ! -d  $INFLUX_CONF ]; then
    mkdir -p $INFLUX_CONF
    writeLog "$INFLUX_CONF created"
  else
    writeLog "$INFLUX_CONF already present"
  fi

}


runDocker()
{
  if ! isRunned ; then
    writeLog "run influx docker"
    docker run -d --name=$DOCKERNAME \
        --restart=always \
        -p $VIP:8086:8086 \
        -p $VIP:25826:25826/udp \
        -e INFLUXDB_GRAPHITE_ENABLED=true \
        -v $INFLUX_DATA:/var/lib/influxdb \
        -v $INFLUX_CONF/influxdb.conf:/etc/influxdb/influxdb.conf:ro \
        -v $INFLUX_TYPESDB/collectd-types.db:/usr/share/collectd/types.db:ro \
	-v /backup:/backup \
        $DOCKERIMAGE:$DOCKERVERSION -config /etc/influxdb/influxdb.conf
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


restoreDB()
{

#  writeLog "removing old backup data"
#  sudo rm -rf /docker/influxdb/data/

  writeLog "restoring influx ha db"
  docker exec -it $DOCKERNAME influxd restore -portable -db ha /backup/influx.bck/ha
  writeLog "restored"

  writeLog "restoring influx telegraf db"
  docker exec -it $DOCKERNAME influxd restore -portable -db telegraf /backup/influx.bck/telegraf
  writeLog "restored"

}

backupDB()
{

  writeLog "deleting old backup"
  sudo rm /backup/influx.bck/ha/*
  sudo rm /backup/influx.bck/telegraf/*

  writeLog "backup ha db"
  docker exec -i $DOCKERNAME influxd  backup -portable -db ha /backup/influx.bck/ha
  writeLog "done"

  writeLog "backup telegraf db"
  docker exec -i $DOCKERNAME influxd  backup -portable -db telegraf /backup/influx.bck/telegraf
  writeLog "done"

}

main "$@"

exit
