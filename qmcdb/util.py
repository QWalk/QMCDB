"""
Utility functions
"""
import os, json

def resource_dir_path(modfile, resdir="data"):
    """
    return the absolute file path to the directory containing resources for
    a module.  

    This function allows a module set the directory within its package that 
    it will load resource data from.
    
    Parameters
    ----------
    modfile : str
       the module's __file__
    resdir : str
       a relative path to the resource data directory.  The default is "data",
       meaning the "data" subdirectory located in the same directory as the 
       module's file.  Use "../data" to indicate a subdirectory of the module's 
       parent.  
    """
    rdir = os.path.join(os.path.dirname(modfile), resdir)
    return os.path.abspath(rdir)

def load_json_from_file(filename, dir=None):
    """
    load the JSON data in from a file.  

    This function aids in loading data from a resource file

    Parameters
    ----------
    filename : str      
       the path to the file to load; can be relative.
    dir : str
       a directory that the filename path is relative to
    """
    if dir:
        filename = os.path.join(dir, filename)
    with open(filename) as fd:
        return json.load(fd)
