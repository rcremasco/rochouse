#!/bin/bash

APP="/docker"
MM_ROOT="$APP/magicmirror"
MM_CONF="$MM_ROOT/config"
MM_MODULES="$MM_ROOT/modules"

if [ -d "$MM_ROOT" ]
then
	echo "MagicMirror data already present"
else
	echo "no MagicMirror data, creating folder"
	mkdir -p $MM_ROOT
	mkdir -p $MM_CONF
	mkdir -p $MM_MODULES
fi

docker stop mm
docker rm mm

docker pull bastilimbach/docker-magicmirror

docker run -d \
	--publish 82:8080 \
	--restart always \
	--name mm \
	-v $MM_CONF:/opt/magic_mirror/config \
	-v $MM_MODULES:/opt/magic_mirror/modules \
	-v /etc/localtime:/etc/localtime:ro \
	bastilimbach/docker-magicmirror

docker update  --restart=unless-stopped mm

docker start mm

