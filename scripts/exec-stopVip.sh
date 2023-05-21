#!/bin/bash

SCRIPTPATH=$(dirname $0)
source $SCRIPTPATH/exec-common.sh


#sudo ip address del $VIP/24 dev wlan0
#sudo ip address del $VIP/24 dev eth0
INT="$(ip r | grep default | awk '{print $5}')"
writeLog "Disattivazione IP $VIP da interfaccia $INT"

sudo ip address del $VIP/24 dev $INT
