SCRIPTPATH=$(dirname $0)
LOGFILE="/tmp/startup.log"
export LOGFILE

source $SCRIPTPATH/exec-common.sh

writeLog "INFO - Startup..."
writeLog "INFO - Controllo connettività."

maxRetry=20;
i=0;
netOk=0;
while [ ! $netOk -eq 1 ];
do
  if ping -c 1 192.168.10.1 > /dev/null; then
    writeLog "INFO - OK raggiungo il default gateway, procedo...."
    netOk=1;
  else
    writeLog "WARNING - Non raggiungo il default gateway "
  fi

  i=$(( $i+1 ))

  if [ $i -ge $maxRetry ]; then
    writeLog "ERROR - Scaduto tempo di attesa default gateway"
    writeLog "ERROR - Esco dalla procedura..."
    exit 1
  fi

done

i=0;
netOk=0;
while [ ! $netOk -eq 1 ];
do
  if ping -c 1 8.8.8.8 > /dev/null; then
    writeLog "INFO - Connessione Internet OK, procedo..."
    netOk=1;
  else
    writeLog "WARNING - Connessione internet assente"
  fi

  i=$(( $i+1 ))

  if [ $i -ge $maxRetry ]; then
    writeLog "ERROR - Scaduto tempo di attesa internet"
    writeLog "INFO - Procedo senza connessione internet"
  fi

done

$SCRIPTPATH/exec-startVip.sh
$SCRIPTPATH/exec-deconz.sh start
$SCRIPTPATH/exec-influx2.sh start
$SCRIPTPATH/exec-mosquitto.sh start
$SCRIPTPATH/exec-homeassistant.sh start
$SCRIPTPATH/exec-nodered.sh start
$SCRIPTPATH/exec-chain2.sh start
$SCRIPTPATH/exec-hik2ha-wrapper.sh start
$SCRIPTPATH/exec-grafana.sh start
$SCRIPTPATH/exec-weewx.sh start
$SCRIPTPATH/exec-httpd-weewx.sh start
$SCRIPTPATH/exec-magicmirror.sh start

writeLog "INFO - end of Startup..."
