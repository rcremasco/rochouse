#!/bin/bash

APP="/docker"
NODERED_ROOT="$APP/nodered"

if [ -d "$NODERED_ROOT" ]
then
	echo "nodered data already present"
else
	echo "no nodered data, creating folder"
	mkdir -p $NODERED_ROOT
	sudo chown -R pi:pi $NODERED_ROOT
fi

docker stop nodered
docker rm nodered



cat << EOF > /docker/nodered/addon.sh
cd /data
npm install node-red-contrib-actionflows \
    node-red-contrib-home-assistant-websocket \
    node-red-contrib-stoptimer \
    node-red-contrib-time-range-switch \
    node-red-contrib-timecheck \
    node-red-dashboard \
    node-red-contrib-moment \
    node-red-node-email \
    node-red-contrib-telegrambot \
    node-red-contrib-alexa-remote2 \
    node-red-contrib-loop-processing \
    node-red-contrib-deconz \
    node-red-contrib-influxdb \
    node-red-node-timeswitch 
EOF

chmod +x /docker/nodered/addon.sh


docker run -d -p 1880:1880 \
        -p 3456:3456 \
	--name nodered \
        -u 1000:1000 \
	-v $NODERED_ROOT:/data \
        -e "TZ=Europe/Rome" \
	nodered/node-red
docker update  --restart=unless-stopped nodered

docker exec -t nodered /bin/bash -c "/data/addon.sh"

docker stop nodered
docker start nodered

