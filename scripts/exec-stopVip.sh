
SCRIPTPATH=$(dirname $0)
source $SCRIPTPATH/exec-common.sh


sudo ip address del $VIP/24 dev wlan0
