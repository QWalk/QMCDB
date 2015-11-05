#! /bin/bash
#
# Usage: labs-mongo-ctl.sh start|stop|status
#
# Start or stop the mongo server
#
prog=$0
exedir=`dirname $prog`
exe=`basename $prog`
set -e
source $exedir/labs-config.sh
source $exedir/labs-funcs.sh

init QMCDB_BASE="qmc"
init QMCDB_SRVR_IMG_NAME=mongo:latest
init QMCDB_SRVR_IMG_OPTS=""
init QMCDB_SRVR_CONTAINER_NAME=${QMCDB_BASE}-mongo
init QMCDB_SRVR_MONGO_PORT=32500
init QMCDB_DB_HOST_PATH=/data/qmcdb

function start {
    dbstatus=`dbserver_status`

    case $dbstatus in 
        "exited" )
            echo "Restarting MongoDB server..." 1>&2
            docker start $QMCDB_SRVR_CONTAINER_NAME > /dev/null
            ;;
        "running" )
            echo "MongoDB server ($QMCDB_SRVR_CONTAINER_NAME) is already" \
                 "running" 1>&2
            ;;
        * )
            run="docker run --name $QMCDB_SRVR_CONTAINER_NAME             \
                            -v ${QMCDB_DB_HOST_DATAPATH}:/data/db         \
                            -v ${QMCDB_DB_HOST_APPPATH}:/QMCDB            \
                            -p ${QMCDB_SRVR_MONGO_PORT}:27017 -d          \
                            $QMCDB_SRVR_IMG_NAME $QMCDB_SRVR_IMG_OPTS"
            echo $run 1>&2
            pid=`$run`

            dbstatus=`dbserver_status`
            if [ "$dbstatus" != "running" ]; then
                echo "Failed to start server container"
                return 1
            else
                echo "Started server container (${pid:1:12})."
            fi
            ;;
    esac

    return 0
}

function stop {
    dbstatus=`dbserver_status`

    case $dbstatus in 
        "running" )
            docker stop --time=3 $QMCDB_SRVR_CONTAINER_NAME > /dev/null
            sleep 4
            dbstatus=`dbserver_status`
            [ "$dbstatus" != "running" ] && echo "Stopped server container."
            ;;
        * )
            echo "Server is already $dbstatus."
            ;;
    esac

    case $dbstatus in 
        "running" )
            echo "Failed to stop server container"
            return 1
            ;;
        "exited" )
            docker rm $QMCDB_SRVR_CONTAINER_NAME > /dev/null 2>&1 || \
                echo "Warning: Failed to remove stopped container." 1>&2
            ;;
    esac

    return 0
}

function status {
    dbstatus=`dbserver_status`

    case $dbstatus in 
        "running" ) 
            echo DB Server is running
            ;;
        "exited" )
            echo "DB Server has exited (but still listed)"
            ;;
        * )
            echo DB Server is not running
            ;;
    esac

    return 0
}

cmd=$1
shift

case $cmd in 
    "start" )
        start "$@"
        ;;
    "stop" )
        stop
        ;;
    "status" )
        status
        ;;
esac

