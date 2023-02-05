
SCRIPTPATH=$(dirname $0)
source $SCRIPTPATH/exec-common.sh


sudo ip address add $VIP/24 dev wlan0

