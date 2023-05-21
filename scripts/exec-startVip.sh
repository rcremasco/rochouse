#!/bin/bash

SCRIPTPATH=$(dirname $0)
source $SCRIPTPATH/exec-common.sh


if ping -c 1 $VIP  > /dev/null; then
  writeLog "INFO - IP $VIP già attivo."
  netOk=1;
else
  writeLog "INFO - attivazione IP $VIP"
  #sudo ip address add $VIP/24 dev eth0
  INT="$(ip r | grep default | awk '{print $5}')"
  writeLog "INFO - Attivazione IP $VIP su interfaccia $INT"
  sudo ip address add $VIP/24 dev $INT
fi

if ping -c 1 $VIP  > /dev/null; then
  writeLog "INFO - OK IP $VIP attivo."
  netOk=1;
else
  writeLog "ERROR - attivazione IP $VIP fallita"
fi


#sudo ip address add $VIP/24 dev wlan0
#sudo ip address add $VIP/24 dev eth0

