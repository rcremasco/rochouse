#!/bin/bash

APP="/docker"
TELEGRAF_ROOT="$APP/telegraf"

mkdir -p $TELEGRAF_ROOT

#docker run --rm telegraf telegraf config > $TELEGRAF_ROOT/telegraf.conf

docker stop telegraf
docker rm telegraf

docker pull telegraf

docker run \
	--name=telegraf \
	-v $TELEGRAF_ROOT/telegraf.conf:/etc/telegraf/telegraf.conf:ro \
	telegraf
docker update  --restart=unless-stopped telegraf

docker  start telegraf

