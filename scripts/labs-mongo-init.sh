#! /bin/bash
#
# Usage: labs-mongo-init.sh 
#
# Initialize and start the MongoDB server in a docker container.  This script
# is run only once in a newly configured docker host.  Currently, the docker
# host is a single openstack machine instance.  This script assumes that the
# docker host's filesystem has been setup and both docker and the QMCDB
# software have been installed.  
#
prog=$0
exedir=`dirname $prog`
exe=`basename $prog`
set -e
source $exedir/labs-config.sh
source $exedir/labs-funcs.sh

init QMCDB_BASE="qmc"
init QMCDB_SRVR_CONTAINER_NAME=${QMCDB_BASE}-mongo
init QMCDB_SRVR_MONGO_PORT=32500

init QMCDB_SETUP_IMG_NAME=${QMCDB_BASE}db/mdbclient:latest
init QMCDB_SETUP_IMG_OPTS="/bin/bash"
init QMCDB_SETUP_CONTAINER_NAME=${QMCDB_BASE}-user-setup

dbstatus=`dbserver_status`
if [ "$dbstatus" == "running" ]; then
    echo "MongoDB server is already running; stop server before initializing"
    exit 1
fi
[ "$dbstatus" != "exited" ] || docker rm ${QMCDB_BASE}-mongo

# start the server with no authentication set to create users.  Note that
# we can't use $QMCDB_SRVR_IMG_OPTS because the config file conflicts with
# --noauth
#set -x
pid=`docker run --name $QMCDB_SRVR_CONTAINER_NAME             \
                -v ${QMCDB_DB_HOST_DATAPATH}:/data/db         \
                -v ${QMCDB_DB_HOST_APPPATH}:/QMCDB            \
                -p ${QMCDB_SRVR_MONGO_PORT}:27017 -d          \
                $QMCDB_SRVR_IMG_NAME --noauth`
if [ "$?" != 0 ]; then
    echo "${prog}: Unable to start MongoDB server container" 1>&2
    exit 2
fi

set +e
docker run -it --rm  --name $QMCDB_SETUP_CONTAINER_NAME \
           --link ${QMCDB_SRVR_CONTAINER_NAME}:db       \
           -v ${QMCDB_DB_HOST_APPPATH}:/QMCDB           \
           $QMCDB_SETUP_IMG_NAME $QMCDB_SETUP_IMG_OPTS  \
           "/QMCDB/scripts/qmcdb-init.py /QMCDB/conf"
initok=$?
set -e

$exedir/labs-mongo-ctl.sh stop

if [ "$initok" != "0" ]; then
    echo "${prog}: Failed to initialize MongoDB database"  1>&2
    exit 3
fi

echo "Restarting MongoDB server..."

$exedir/labs-mongo-ctl.sh start


