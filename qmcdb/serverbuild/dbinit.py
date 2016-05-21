"""
functions that initialize the MongoDB database
"""

import json, sys, os
from warnings import warn
from ..util import resource_dir_path, load_json_from_file

resource_dir = resource_dir_path(__file__, "data")

def load_json_resource(resname):
    return load_json_from_file(resname+".json", resource_dir)

def create_admin_user(client, password, username=None):
    """Deprecated"""
    inputs = load_json_resource("adminuser")
    if not username:
        username = inputs.get("user") or "admin"
    if not client.admin.add_user(username, password, roles=inputs["roles"]):
        return False

    return True

def init_users(client, conffile):
    """
    create the initial set of users from the given user configuration file.

    See conf/userinit.json_template for format. 
    """
    try:
        userdata = load_json_from_file(conffile)
    except ValueError, e:
        raise RuntimeError("Failed to load config file, " +
                           os.path.basename(conffile) + ": " + str(e))
    if not userdata: 
        warn("No initial user accounts found", RuntimeWarning)
    if not userdata.has_key("admin"):
        warn("No admin user configuration included", RuntimeWarning)

    for usertype in userdata:
        data = userdata[usertype]
        if not data.get("authdb"):
            warn("No authentication database specified for '"+usertype+ \
                     "'; skipping")
            continue
        if not data.get("roles"):
            warn("No user access roles specified for '"+usertype+ \
                     "'; skipping")
            continue
        if not data.get("users"):
            continue

        if type(data["authdb"]) is not list:
            data["authdb"] = [data["authdb"]]
        for authdb in data["authdb"]:
          for user in data["users"]:
            if user["pw"] == "password":
                raise RuntimeError("password not set for user, "+
                                   user["username"])
            client[str(authdb)].add_user(user["username"], user["pw"],
                                         roles=data["roles"])
        print >> sys.stderr, "Added "+usertype+": "+ \
            ', '.join(map(lambda u: u["username"], data["users"]))

def init_dbs(client, conffile):
    """
    load some initial data into some databases.  

    With MongoDB, databases (and collections) are not created until some 
    data is loaded into them.
    """
    try:
        dbdata = load_json_from_file(conffile)
    except ValueError, e:
        raise RuntimeError("Failed to load config file, " +
                           os.path.basename(conffile) + ": " + str(e))
    if not dbdata: 
        warn("Initial db data file ("+os.path.basename(conffile)+") is empty",
             RuntimeWarning)
        return 

    for dbname in dbdata:
      for collname in dbdata[dbname]:
        client[str(dbname)][str(collname)].insert_one(dbdata[dbname][collname])
      print >> sys.stderr, "Initialized the "+dbname+" database."

def init(client, confdir):
    """
    initialize the database.

    This assumes MongDB has been started with --noauth
    """
    if not os.path.isdir(confdir):
        raise RuntimeError(confdir+": does not exist as a directory")

    # initialize the users
    conf = os.path.join(confdir, "userinit.json")
    init_users(client, conf)

    conf = os.path.join(confdir, "dbinit.json")
    init_dbs(client, conf)

    



