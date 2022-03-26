#!/bin/bash

VIP="192.168.10.5"

writeLog()
{

    echo "$(date +"%Y/%m/%d %H:%M:%S") - $1"
#    echo "$(date +"%Y/%m/%d %H:%M:%S") - $1" >> /tmp/backup.log

}

isRunned()
{
  if [ $(docker ps -a | grep $DOCKERNAME | wc -l) -eq 1 ]; then
    # true=0
    return 0
  else
    # false=1
    return 1
  fi
}

isRunning()
{
  if [[ "$(docker ps --format '{{.Status}}' --filter "name=$DOCKERNAME" -a)" =~ "Up" ]]; then
    # true=0
    return 0
  else
    # false=1
    return 1
  fi
}

status()
{

  writeLog "$DOCKERNAME status"
  docker ps --filter "name=$DOCKERNAME" -a 
}

restoreDB()
{
  writeLog "restoreDB not Implemented"
}

backupDB()
{
  writeLog "backupDB not Implemented"
}


setupFolder()
{
  writeLog "setupFolder not Implemented"
}

runDocker()
{
  writeLog "runDocker not Implemented"
}

setupDocker()
{
  writeLog "setupDocker not Implemented"
}



removeImage()
{
  if [ $(docker image ls | grep $DOCKERIMAGE | wc -l) -ge 1 ]; then
    writeLog "removing image $DOCKERIMAGE"
    docker image rm $(docker image ls | grep $DOCKERIMAGE | awk  '{print $3}')
  else
    writeLog "$DOCKERIMAGE image not found"
  fi
}

stopDocker()
{
  if [ $(docker ps | grep $DOCKERNAME | wc -l) -eq 1 ]; then
    writeLog "stopping $DOCKERNAME docker"
    docker stop $DOCKERNAME
    writeLog "stopped"
  else
    writeLog "$DOCKERNAME already stopped"
  fi
}

removeDocker()
{

  stopDocker

  if [ $(docker ps -a | grep $DOCKERNAME | wc -l) -eq 1 ]; then
    writeLog "removing $DOCKERNAME docker"
    docker rm $DOCKERNAME
    writeLog "$DOCKERNAME removed"
  else
    writeLog "$DOCKERNAME docker already removed"
  fi
}

pullDocker()
{
  writeLog "pulling $DOCKERNAME image"
  docker pull $DOCKERIMAGE:$DOCKERVERSION
  writeLog "$DOCKERNAME pulled"
}

setupDocker()
{
  writeLog "setting docker"
  docker update  --restart=unless-stopped $DOCKERNAME
}


startDocker()
{
  if ! isRunning ; then
    if [ $(docker ps -a | grep $DOCKERNAME | wc -l) -eq 0 ]; then
      writeLog "$DOCKERNAME docker not present, call run"
      runDocker
    fi

    writeLog "start $DOCKERNAME docker"
    docker start $DOCKERNAME
    writeLog "$DOCKERNAME started"
  else
    writeLog "$DOCKERNAME already running"
  fi
}

saveImage()
{
  if [ ! -d /backup/images/$DOCKERNAME ]; then
    writeLog "creating backup folder"
    sudo mkdir -p /backup/images/$DOCKERNAME/
    sudo chown pi:pi /backup/images/$DOCKERNAME/
  fi
  writeLog "starting $DOCKERIMAGE docker image save"
  docker save --output /backup/images/$DOCKERIMAGE/$DOCKERIMAGE.tar $DOCKERNAME
  writeLog "$DOCKERIMAGE save compelted"
}

loadImage()
{
  if [ -f /backup/images/$DOCKERIMAGE/$DOCKERIMAGE.tar ]; then
    writeLog "start loading $DOCKERIMAGE image"
    docker load  -i /backup/images/$DOCKERIMAGE/$DOCKERIMAGE.tar 
    writeLog "$DOCKERIMAGE load completed"
  else
    writeLog "backup image not found /backup/images/$DOCKERIMAGE/$DOCKERIMAGE.tar"
  fi
}

main()
{

while [[ $# -gt 0 ]]; do
    key="$1"
    case "$key" in
        # 
        run)
          runDocker
        ;;
        # 
        stop)
          stopDocker
        ;;
        # 
        start)
          startDocker
        ;;
        # 
        remove)
          removeDocker
	;;
	restoredb)
	  restoreDB
	;;
        backupdb)
          backupDB
        ;;
	save)
	  saveImage
	;;
	load)
	  loadImage
	;;
        removeImage)
	  removeImage
	;;
	status)
	  status
	;;
        setup)
          setupFolder
	  removeDocker
	  pullDocker
	  runDocker
	  setupDocker
        ;;
        *)
        # Do whatever you want with extra options
        writeLog "Unknown option '$key'"
	writeLog "possible options are: run start stop status save load restoredb backupdb remove removeImage setup"
        ;;
    esac
    # Shift after checking all the cases to get the next option
    shift
done
 
}
