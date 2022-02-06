#!/bin/bash

APP="/docker"
ZOOKEEPER_ROOT="$APP/zookeeper"

if [ -d "$ZOOKEEPER_ROOT" ]
then
	echo "zookeeper data already present"
else
	echo "no zookeeper data, creating folder"
	mkdir -p $ZOOKEEPER_ROOT
	sudo chown -R 1001:1001 $ZOOKEEPER_ROOT
fi

if [ -d "$ZOOKEEPER_ROOT/conf" ]
then
	echo "zookeeper conf already present"
else
        echo "no zookeeper conf, creating folder"
        sudo mkdir -p $ZOOKEEPER_ROOT/conf
        sudo chown -R 1001:1001 $ZOOKEEPER_ROOT/conf
fi


docker stop zookeeper
docker rm zookeeper



docker run -d -p 2181:2181 \
	-p 2888:2888 \
	-p 3888:3888 \
	-p 8080:8080 \
	--name zookeeper \
	-e ALLOW_ANONYMOUS_LOGIN=yes \
	-v $ZOOKEEPER_ROOT:/bitnami/zookeeper \
	-v $ZOOKEEPER_ROOT/conf:/opt/bitnami/zookeeper/conf \
	bitnami/zookeeper:latest
docker update  --restart=unless-stopped zookeeper


#        -e "TZ=Europe/Rome" \
#        -e ZOO_SERVER_ID=1 \
#        -e ZOO_SERVERS=0.0.0.0:2888:3888,zookeeper2:2888:3888,zookeeper3:2888:3888 \

