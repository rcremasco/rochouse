#!/bin/bash

APP="/docker"
CHAIN2_ROOT="$APP/chain2"

if [ -d "$CHAIN2_ROOT" ]
then
	echo "chain2 data already present"
else
	echo "no chain2 data, creating folder"
	mkdir -p $CHAIN2_ROOT
	sudo chown -R pi:pi $CHAIN2_ROOT
fi

docker stop chain2
docker rm chain2

cd chain2
docker build  -t chain2 .
cd

cp chain2/websock.py /docker/chain2

docker run -d  \
	--name chain2 \
        -u 1000:1000 \
	-v $CHAIN2_ROOT:/app \
        -e "TZ=Europe/Rome" \
	chain2
docker update  --restart=unless-stopped chain2


docker stop chain2
docker start chain2

