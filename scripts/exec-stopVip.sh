
SCRIPTPATH=$(dirname $0)
source $SCRIPTPATH/exec-common.sh


#sudo ip address del $VIP/24 dev wlan0
sudo ip address del $VIP/24 dev eth0
