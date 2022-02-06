#!/bin/bash

APP="/docker"
GRAFANA_ROOT="$APP/grafana"
GRAFANA_CONF="$APP/grafana/etc/grafana.ini"

if [ -d "$GRAFANA_ROOT" ]
then
	echo "grafana data already present"
else
	echo "no grafana data, creating folder"
	mkdir -p $GRAFANA_ROOT
	sudo chown -R 472:472 $GRAFANA_ROOT
fi

docker stop grafana
docker rm grafana

docker pull grafana/grafana

docker run -d -p 3000:3000 \
	--name grafana \
	-v $GRAFANA_ROOT:/var/lib/grafana \
	-v $GRAFANA_CONF:/etc/grafana/grafana.ini \
	grafana/grafana
docker update  --restart=unless-stopped grafana

docker start grafana

