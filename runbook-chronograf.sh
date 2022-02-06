#!/bin/bash

APP="/docker"
CHRONOGRAF_ROOT="$APP/chronograf"

mkdir -p $CHRONOGRAF_ROOT

docker stop chronograf
docker rm chronograf


docker pull chronograf

docker run -d --name=chronograf -p 8888:8888 \
	-v $CHRONOGRAF_ROOT:/var/lib/chronograf \
	--restart=always chronograf \
	--influxdb-url=http://192.168.10.4:8086


docker update  --restart=unless-stopped chronograf
docker start chronograf

