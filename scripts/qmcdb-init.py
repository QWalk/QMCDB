#! /usr/bin/python
#
# Usage:  qmcdb-init.py CONFDIR [HOST] [PORT]
#

from qmcdb.serverbuild import dbinit
from pymongo import MongoClient
import sys, os

if len(sys.argv) < 2:
    print >> sys.stderr, "Missing config dir argument."
    sys.exit(1)

if os.environ.has_key("DB_PORT"):
    try:
        conninfo = os.environ["DB_PORT"].split(':')
        if len(conninfo) == 3:
            port = int(conninfo[2])
            host = conninfo[1].strip('/')
    except ValueError:
        pass

if len(sys.argv) > 2:
    host = sys.argv[2]
elif not host:
    print >> sys.stderr, "Missing host name argument"
    sys.exit(1)

if len(sys.argv) > 3:
    try:
        port = int(sys.argv[3])
    except ValueError, ex:
        print >> sys.stderr, "Bad port argument: Not a number: "+sys.argv[3]
        sys.exit(1)
elif not port:
    print >> sys.stderr, "Missing port number argument"
    sys.exit(1)
    
confdir = sys.argv[1]


try: 
    client = MongoClient(host, port)
    # print "host="+host+"; port="+str(port)+"; conf="+confdir

    dbinit.init(client, confdir)

except Exception, ex:
    print >> sys.stderr, "Init failed: " + str(ex)
    sys.exit(2)





