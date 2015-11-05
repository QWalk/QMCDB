#!/bin/bash
#
set -e

if [ "${1:0:1}" = '-' ]; then
	set -- mongo --authenticationDatabase qmc "$@"
fi

if [ "$1" = 'mongod' ]; then
	echo "Use the qmc server container to start the database."
        exit 1
fi

exec "$@"
