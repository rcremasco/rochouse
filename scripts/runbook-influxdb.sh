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

# Creazione directory
mkdir -p $INFLUX_DATA ; mkdir -p $INFLUX_CONF

docker stop influxdb
docker rm influxdb

docker pull influxdb:1.8

docker run --name=influxdb \
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

docker update  --restart=unless-stopped influxdb

docker start influxdb
