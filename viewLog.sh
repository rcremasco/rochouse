CONTAINER=$1

if [ "$CONTAINER" == "" ]; then
        echo "Usage: viewlog <container nam>"
        exit 1
fi

LOGFILE=$(docker inspect $CONTAINER | grep LogPath| tr -d , | tr -d '"' |awk -F ":" '{print $2}')

if [ "$LOGFILE" == "" ]; then
        echo "container $CONTAINER not found"
else
        sudo tail -f $LOGFILE
fi

