# This file defines general bash functions useful for interacting (e.g.
# starting, stopping) NDS labs/docker resources.
#
# This is expected to be sourced by bash scripts after labs-config.sh
#
if [ -z "$QMCDB_" ]; then
    echo "Config file, labs-config.sh, has not been sourced" 1>&2
    false
fi

declare -g tmpfiles=""

function create_tmpfile {
    # local -g tmpfiles
    local base=${QMCDB_BASE}
    local num=$(date -u +%Y%j%H%M%S%N | sum | awk '{print $1}')
    local file=$QMCDB_TMPDIR/${base}-${num}.tmp
    [ ! -e "$file" ] || file=${base}-$(date -u +%Y%j%H%M%S%N | sum).tmp
    [ -e "$file" ] && return 1
    tmpfiles="$tmpfiles $file"
    touch $file
    echo $file
}

function delete_tmpfiles {
    # this isn't working at the moment
    for file in $tmpfiles; do
        [ -e "$file" ] && rm -f "$file" || \
            echo "Warning: failed to remove $file"
    done
}

function docker_ps_datum {
    # select out a column of data from a docker ps command result
    # 
    # Usage: docker_ps_datum COLNAME --filter "FILT" ...
    # 
    local item=`echo $1 | tr a-z A-Z`
    [ "$item" = "ID" ] && item="COMMAND ID"
    shift
    local tmpf=`create_tmpfile`

    docker ps "$@" > $tmpf || return 1
    [ $(cat $tmpf |wc -l) = "1" ] && return 0

    local cols=`head -1 $tmpf | grep -bo $item | sed -e 's/:.*//'`
    local coll=`head -1 $tmpf | sed -re 's/.{'$cols'}//' -e 's/  [A-Z].*/ /' | wc -c`
    local line=`tail -n -1 $tmpf`
    #rm -f $tmpf || true
    eval echo '${line:'${cols}:$coll'}'
}

function container_status {
    # print the status of a docker container 
    local name=$1
    [ -n "$name" ] || {
        echo "container_status: missing container name argument"
        return 1
    }

    local status=`docker_ps_datum STATUS -a --filter "name=$name"`
    case $status in 
        "Up "*     )
            echo "running"
            ;;
        "Exited "* )
            echo "exited"
            ;;
        ""         )
            echo "removed"
            ;;
        * )
            echo $status
            ;;
    esac
    return 0
}

function dbserver_status {
    # print the status of the mongodb container
    local name=$1
    [ -n "$name" ] || name=$QMCDB_SRVR_CONTAINER_NAME

    container_status $name
}


