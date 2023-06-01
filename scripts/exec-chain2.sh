#!/bin/bash


APP="/docker"
DOCKERNAME="chain2"
DOCKERIMAGE="chain2"
DOCKERVERSION="latest"
CHAIN2_ROOT=$APP/$DOCKERNAME

SCRIPTPATH=$(dirname $0)
source $SCRIPTPATH/exec-common.sh

setupFolder()
{
  # Creazione directory
  if [ ! -d  $CHAIN2_ROOT ]; then
    sudo mkdir -p $CHAIN2_ROOT
    sudo chown -R $USER:$USER $CHAIN2_ROOT
    writeLog "$CHAIN2_ROOT created"
  else
    writeLog "$CHAIN2_ROOT already present"
  fi

}


runDocker()
{
  if ! isRunned ; then
    writeLog "buildind image"
    cd /home/$USER/rochouse/chain2
    docker build  -t chain2 .
    cd $SCRIPTPATH


    writeLog "run $DOCKERNAME docker"
    docker run -d --name=$DOCKERNAME \
        -u 1000:1000 \
        -v $CHAIN2_ROOT:/app \
        -e "TZ=Europe/Rome" \
        $DOCKERIMAGE
    writeLog "runed"

    setupDocker
  else
    writeLog "$DOCKERNAME already running"
  fi

}

setupDocker()
{
  writeLog "setting docker"
  docker update  --restart=unless-stopped $DOCKERNAME
}


main "$@"

exit
