
docker stop home-assistant
docker rm home-assistant
docker pull homeassistant/raspberrypi3-homeassistant
docker run -d --name="home-assistant" \
	-v /docker/homeassistant:/config \
	-v /etc/localtime:/etc/localtime:ro \
	--privileged \
	--net=host homeassistant/raspberrypi3-homeassistant:stable
docker update  --restart=unless-stopped home-assistant

docker start home-assistant

