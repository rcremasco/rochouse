#|/bin/bash
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

writeLog()
{

    echo "$(date +"%Y/%m/%d %H:%M:%S") - $1"
#    echo "$(date +"%Y/%m/%d %H:%M:%S") - $1" >> /tmp/backup.log

}


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

stopDocker()
{
  if [ $(docker ps | grep influx | wc -l) -eq 1 ]; then
    writeLog "stopping influx docker"
    docker stop influxdb
    writeLog "stopped"
  else
    writeLog "already stopped"
  fi
}

removeDocker()
{

  stopDocker

  if [ $(docker ps -a | grep influx | wc -l) -eq 1 ]; then
    writeLog "removing influx docker"
    docker rm influxdb
    writeLog "removed"
  else
    writeLog "docker already removed"
  fi
}

pullDocker()
{
  writeLog "pulling influx image"
  docker pull influxdb:1.8
  writeLog "pulled"
}

setupDocker()
{
  writeLog "setting docker"
  docker update  --restart=unless-stopped influxdb
}

runDocker()
{
  writeLog "run influx docker"
  docker run -d --name=influxdb \
        --restart=always \
        -p 8086:8086 \
        -p 25826:25826/udp \
        -e INFLUXDB_GRAPHITE_ENABLED=true \
        -v $INFLUX_DATA:/var/lib/influxdb \
        -v $INFLUX_CONF/influxdb.conf:/etc/influxdb/influxdb.conf:ro \
        -v $INFLUX_TYPESDB/collectd-types.db:/usr/share/collectd/types.db:ro \
	-v /backup:/backup \
        influxdb:1.8 -config /etc/influxdb/influxdb.conf
#        influxdb:$VERSION -config /etc/influxdb/influxdb.conf
  writeLog "runed"

  setupDocker

}

setupDocker()
{
  writeLog "setting docker"
  docker update  --restart=unless-stopped influxdb
}

startDocker()
{
  if [ $(docker ps -a | grep influx | wc -l) -eq 0 ]; then
    writeLog "docker not present, call run"
    runDocker
  fi

  writeLog "start docker"
  docker start influxdb
  writeLog "started"
}

restoreDB()
{

  writeLog "restoring ha db"
  docker exec -it influxdb influxd restore -portable -db ha /backup/influx.bck/ha
  writeLog "restored"

  writeLog "restoring telegraf db"
  docker exec -it influxdb influxd restore -portable -db telegraf /backup/influx.bck/telegraf
  writeLog "restored"

}

backupDB()
{

  writeLog "deleting old backup"
  rm /backup/influx.bck/ha/*
  rm /backup/influx.bck/telegraf/*

  writeLog "backup ha db"
  docker exec -i influxdb influxd  backup -portable -database ha -host 127.0.0.1:8088 /backup/influx.bck/ha
  writeLog "done"

  writeLog "backup telegraf db"
  docker exec -i influxdb influxd  backup -portable -database telegraf -host 127.0.0.1:8088 /backup/influx.bck/telegraf
  writeLog "done"

}

saveImage()
{
  if [ ! -d /backup/images/influxdb ]; then
    writeLog "creating backup folder"
    sudo mkdir -p /backup/images/influxdb/
    sudo chown pi:pi /backup/images/influxdb/
  fi
  writeLog "starting docker image save"
  docker save --output /backup/images/influxdb/influxdb.tar influxdb
  writeLog "save compelted"
}

loadImage()
{
  if [ -f /backup/images/influxdb/influxdb.tar ]; then
    writeLog "start loading influx image"
    docker load  -i /backup/images/influxdb/influxdb.tar 
    writeLog "load completed"
  else
    writeLog "backup image not found /backup/images/influxdb/influxdb.tar"
  fi
}

while [[ $# -gt 0 ]]; do
    key="$1"
    case "$key" in
        # 
        run)
          runDocker
        ;;
        # 
        stop)
          stopDocker
        ;;
        # 
        start)
          startDocker
        ;;
        # 
        remove)
          removeDocker
	;;
	restoredb)
	  restoreDB
	;;
        backupdb)
          backupDB
        ;;
	save)
	  saveImage
	;;
	load)
	  loadImage
	;;
        setup)
          setupFolder
	  removeDocker
	  pullDocker
	  runDocker
	  setupDocker
        ;;
        *)
        # Do whatever you want with extra options
        writeLog "Unknown option '$key'"
	writeLog "possible options are: run stop start stop save load restoredb backupdb remove setup"
        ;;
    esac
    # Shift after checking all the cases to get the next option
    shift
done
