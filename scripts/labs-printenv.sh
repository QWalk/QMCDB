#! /bin/bash
#
prog=$0
exedir=`dirname $prog`
exe=`basename $prog`
set -e

echo exedir=$exedir
echo exe=$exe

echo config=$exedir/labs-config.sh
source $exedir/labs-config.sh

printenv | grep QMCDB

