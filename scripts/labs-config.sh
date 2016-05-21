# This file sets environment variables used to setup and managing machines
# and processes within NDS Labs.
#
# This is expected to be sourced by bash scripts
#

export QMCDB_SRVR_MONGO_PORT=32500
export QMCDB_DB_HOST_PATH=/data/qmcdb

export QMCDB_SRVR_IMG_NAME=mongo:latest
export QMCDB_SRVR_IMG_OPTS=""
export QMCDB_=""
# add other customizations here

function init {
    # Usage: init VAR=VAL
    local current
    eval 'current=$'${1%%=*}
    [ -n "$current" ] || export ${1%%=*}="${1#*=}"
}

init QMCDB_BASE="qmc"
init QMCDB_TMPDIR=/tmp

init QMCDB_SRVR_IMG_NAME=mongo:latest
init QMCDB_SRVR_IMG_OPTS="--config /QMCDB/conf/mongod.conf"
init QMCDB_SRVR_CONTAINER_NAME=${QMCDB_BASE}-mongo
init QMCDB_SRVR_MONGO_PORT=32502
init QMCDB_DB_HOST_DATAPATH=/data/qmcdb
init QMCDB_DB_HOST_APPPATH=/app/QMCDB
init QMCDB_SETUP_IMG_NAME=qmcdb/mdbclient:latest
init QMCDB_SETUP_IMG_OPTS="/bin/bash -c"
init QMCDB_SETUP_CONTAINER_NAME=${QMCDB_BASE}-mongo-setup

export QMCDB_="y"
