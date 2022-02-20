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


setupFolder()
{
  # Creazione directory
  if [ ! -d  $INFLUX_DATA ]; then
    mkdir -p $INFLUX_DATA
    echo "$INFLUX_DATA created"
  else
    echo "$INFLUX_DATA already present"
  fi

  if [ ! -d  $INFLUX_CONF ]; then
    mkdir -p $INFLUX_CONF
    echo "$INFLUX_CONF created"
  else
    echo "$INFLUX_CONF already present"
  fi

}

stopDocker()
{
  if [ $(docker ps | grep influx | wc -l) -eq 1 ]; then
    echo "stopping influx docker"
    docker stop influxdb
    echo "stopped"
  else
    echo "already stopped"
  fi
}

removeDocker()
{

  stopDocker

  if [ $(docker ps -a | grep influx | wc -l) -eq 1 ]; then
    echo "removing influx docker"
    docker rm influxdb
    echo "removed"
  else
    echo "docker already removed"
  fi
}

pullDocker()
{
  echo "pulling influx image"
  docker pull influxdb:1.8
  echo "pulled"
}

setupDocker()
{
  echo "setting docker"
  docker update  --restart=unless-stopped influxdb
}

runDocker()
{
  echo "run influx docker"
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
  echo "runed"

  setupDocker

}

setupDocker()
{
  echo "setting docker"
  docker update  --restart=unless-stopped influxdb
}

startDocker()
{
  if [ $(docker ps -a | grep influx | wc -l) -eq 0 ]; then
    echo "docker not present, call run"
    runDocker
  fi

  echo "start docker"
  docker start influxdb
  echo "started"
}

restoreDB()
{

  echo "restoring ha db"
  docker exec -it influxdb influxd restore -portable -db ha /backup/influx.bck/ha
  echo "restored"

  echo "restoring telegraf db"
  docker exec -it influxdb influxd restore -portable -db telegraf /backup/influx.bck/telegraf
  echo "restored"

}

backupDB()
{

  echo "deleting old backup"
  rm /backup/influx.bck/ha/*
  rm /backup/influx.bck/telegraf/*

  echo "backup ha db"
  docker exec -i influxdb influxd  backup -portable -database ha -host 127.0.0.1:8088 /backup/influx.bck/ha
  echo "done"

  echo "backup telegraf db"
  docker exec -i influxdb influxd  backup -portable -database telegraf -host 127.0.0.1:8088 /backup/influx.bck/telegraf
  echo "done"

}

saveImage()
{
  if [ ! -d /backup/images/influxdb ]; then
    echo "creating backup folder"
    sudo mkdir -p /backup/images/influxdb/
    sudo chown pi:pi /backup/images/influxdb/
  fi
  echo "starting docker image save"
  docker save --output /backup/images/influxdb/influxdb.tar influxdb
  echo "save compelted"
}

loadImage()
{
  if [ -f /backup/images/influxdb/influxdb.tar ]; then
    echo "start loading influx image"
    docker load  -i /backup/images/influxdb/influxdb.tar 
    echo "load completed"
  else
    echo "backup image not found /backup/images/influxdb/influxdb.tar"
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
        echo "Unknown option '$key'"
	echo "possible options are: run stop start stop save load restoredb backupdb remove setup"
        ;;
    esac
    # Shift after checking all the cases to get the next option
    shift
done
