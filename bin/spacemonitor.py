#!/bin/python3
import subprocess
import json
import configparser
import string
import os
import gzip
import sys
import getopt
from collections import defaultdict
from time import gmtime, strftime

arguments = {}
config    = []

onstatd = ""
onstatdd = ""

def getArguments(argv):

    arguments 

    try:
        opts, args = getopt.getopt(argv,"he:i:c:f:",["help","env=","ini=","config=","file="])
    except getopt.GetoptError:
         usage()
    
    for opt, arg in opts:
        if opt in ('-h', '--help'):
            usage() 
        elif opt in ("-e", "--env"):
            arguments['env'] = arg
        elif opt in ("-i", "--ini"):
            arguments['ini']=arg
            if not os.path.isfile(arg):
                print ("ini file " + arg + " does not exist ")
                usage()
        elif opt in ("-c", "--config"):
            arguments['config']=arg
            if not os.path.isfile(arg):
                print ("config file " + arg + " does not exist ")
                usage()
        elif opt in ("-f", "--file"):
            arguments['file']=arg
    return arguments

def getCONFIG(value):
    result = subprocess.check_output(['onstat', '-g', 'cfg', value])
    result = result.decode('utf-8')
    
    value="none"

    for line in result.splitlines():
       if 'MSGPATH' in line:
           value=line.split()[1]

    return value

def getData():
    global onstatd, onstatdd, onstatt
    onstatd = getOnstat("-d")
    onstatdd = getOnstat("-D")
    onstatt = getOnstat("-T")

def getInstanceState():
    args = ['onstat', '-']
    result = subprocess.call(args, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

    informixStates = { 
        -1: "GLS locale initialization failed or InformixÂ® failed to attach to shared memory",
        0: "Initialization mode",
        1: "Quiescent mode",
        2: "Recovery mode",
        3: "Backup mode",
        4: "Shutdown mode",
        5: "Online mode",
        6: "Abort mode",
        7: "User mode",
        255: "Off-Line mode"}

    return result
   

def getOnstat(params):
    args = ['onstat']
    args.extend( params.split())
    result = subprocess.check_output(args)
    return result.decode("utf-8")

def getServerType():
    titles("Server Type")
    serverType = onstatRSS.split("Local server type:")[1].split()[0]

    print ("Server Type " + serverType)

def initialise(argv):
    global config 

    arguments = getArguments(argv)

    if not 'config' in arguments:
        arguments['config'] = "/opt/informix/bin/ifxenv.dat"
    if not 'ini' in arguments:
        arguments['ini'] = "./spacemonitor.ini"
    if not 'env' in arguments:
        arguments['env'] = os.getenv('IFXENV', 'none')
        if arguments['env'] == 'none' :
            print ("Environment not set\n")
            usage()
    arguments['time'] = strftime("%y%m%d", gmtime())

    config = configparser.ConfigParser()
    config.read(arguments['ini'])

    if not 'file' in arguments:
        if config.has_option('LOGFILES','DESTINATION'):
            arguments['file'] = config.get('LOGFILES','DESTINATION') + arguments['env'] + "_dbspace" + arguments['time']
        else:
            arguments['file'] = "/opt/informix/stats/" + arguments['env'] + "_dbspace" + arguments['time']

    setEnvironment(arguments)
    informixState = getInstanceState()

    if informixState not in [1,2,3,5,7]:
        sys.exit(1)
          
    return arguments

def setEnvironment(arguments):
    env = configparser.RawConfigParser()
    # set the key to be case sensitive 
    env.optionxform = lambda option: option

    env.read(arguments['config'])  

    path=os.environ["PATH"]
    path=path + ":" + env[arguments['env']]['INFORMIXDIR'] + "/bin" 
    os.environ['PATH'] = path
    for key in env[arguments['env']]:
        os.environ[key] = env[arguments['env']][key]

def getChunkHeat():
    spaces = onstatdd.split("Chunks")[0].split("name")[1]

    lines = spaces.splitlines()

    header = ['dbsnum', 'nchunks', 'pgsize', 'hflags', 'flags', 'owner', 'name']
    spaces = []
    for line in lines[2:-2]:
         fields = line.split()
         d = {}
         d['dbsnum'] = int(fields[1])
         d['nchunks'] = int(fields[4])
         d['pgsize'] = int(fields[5])
         d['hflags'] = fields[2]
         d['flags'] = fields[6:][0:-3]
         d['owner'] = fields[-2]
         d['name'] = fields[-1]
         d['read'] = 0
         d['write'] = 0
         d['used'] = 0
         d['free'] = 0
         spaces.append(d)

    chunks = onstatdd.split("Chunks")[1].split("pathname")[1]

    chks = []

    for line in chunks.splitlines()[1:-8]:
        fields = line.split()
        d = {}
        d['chknum'] = int(fields[1])
        d['dbsnum'] = int(fields[2])
        d['read'] = int(fields[4])
        d['write'] = int(fields[5])
        d['path'] = fields[6]
        chks.append(d)

    chunksd = onstatd.split("Chunks\naddress")[1].split("active,")[0]

    chksd = []

    for line in chunksd.splitlines()[1:-1]:
        fields = line.split()
        d = {}
        d['dbsnum'] = int(fields[2])
        d['size'] = int(fields[4])
        d['free'] = int(fields[5])
        chksd.append(d)

    thisTime=strftime("%Y-%m-%d %H:%M:%S", gmtime())

    
    create_header = not os.path.exists(arguments['file'])

    with open(arguments['file'], 'a+') as output:

        if create_header: 
            output.write("date " + "time " + "space " + "read " + "write " + "used " + "free " + "perc_free\n")

        for i in spaces:
            i['read'] = sum([d['read'] for d in chks if d['dbsnum'] == i['dbsnum']])
            i['write'] = sum([d['write'] for d in chks if d['dbsnum'] == i['dbsnum']])
            i['used'] = sum([d['size'] for d in chksd if d['dbsnum'] == i['dbsnum']])
            i['free'] = sum([d['free'] for d in chksd if d['dbsnum'] == i['dbsnum']])
            output.write(thisTime + " " + i['name'] + " " + str(i['read']) + " " + str(i['write']) + " " + str(i['used']) + " " + str(i['free']) + " " + str(i['free'] * 100.0 / i['used']) + "\n") 
    
# Print a title
def titles(title):
    print("\n--------------------------" + title + "------------------------\n")

def usage():
    print ("Usage:\n")
    print (PROGNAME + ' [-h] [-e <environment>] -i <ini file> -c <env config file> [-f <destination file name>]')
    sys.exit(2)

    
def main(argv): 
    global arguments 
    arguments = initialise(argv)

    getData()
    getChunkHeat() 

#-------------------------------------------------------------------------------------
PROGNAME = sys.argv[0]


if __name__ == "__main__":
   main(sys.argv[1:])
   