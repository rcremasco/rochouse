#!/bin/bash

APP="/docker"
DECONZ_ROOT="$APP/deconz"

if [ -d "$DECONZ_ROOT" ]
then
        echo "deconz data already present"
else
        echo "no deconz data, creating folder"
        mkdir -p $DECONZ_ROOT
fi

if [[ -c /dev/ttyUSB0 ]]
then
	DEV="/dev/ttyUSB0"
	echo "Device $DEV"
fi

if [[ -c /dev/ttyACM0 ]]
then
        DEV="/dev/ttyACM0"
        echo "Device $DEV"
fi


docker stop deconz 
docker rm deconz

IMAGE="deconzcommunity/deconz"


docker pull $IMAGE


if [[ "$1" == "d" ]]
then
        docker run -d --name=deconz --net=host \
                --restart=always \
                --device=$DEV \
                -v /docker/deconz:/opt/deCONZ \
                -e TZ=Europe/Rome \
                -e DECONZ_DEVICE=$DEV \
                -e DECONZ_VNC_MODE=1 \
                -e DECONZ_VNC_PORT=5901 \
                -e DECONZ_WEB_PORT=81 \
		-e DEBUG_APS=1 \
		-e DEBUG_ZCL=1 \
		-e DEBUG_ZDP=1 \
		-e DEBUG_OTAU=1 \
		-e DEBUG_INFO=1 \
                -e DEBUG_ERROR=1 \
                -e DECONZ_START_VERBOSE=1 \
                $IMAGE
else
	docker run -d --name=deconz --net=host \
		--restart=always \
                --device=$DEV \
		-v /docker/deconz:/opt/deCONZ\
                -e DECONZ_DEVICE=$DEV \
                -e TZ=Europe/Rome \
		-e DECONZ_VNC_MODE=1 \
		-e DECONZ_VNC_PORT=5901 \
                -e DECONZ_WEB_PORT=81 \
		$IMAGE
fi

docker update  --restart=unless-stopped deconz


