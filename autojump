#!/usr/bin/python
from __future__ import division
import cPickle
import getopt
from sys import argv
import os
import signal

def signal_handler(arg1,arg2):
    print "Received SIGINT, trying to continue"

signal.signal(signal.SIGINT,signal_handler) #Don't break on sigint

#add the following to your .bashrc:
"""
PROMPT_COMMAND='autojump.py -a $(pwd)'
function j { cd "$(autojump.py $1)"; }
"""

max_keyweight=1000

def dicadd(dic,key,increment=1):
    dic[key]=dic.get(key,0.)+increment

def match(path,pattern,path_dict,re_flags=0):
    import re
    if os.path.realpath(os.curdir)==path : return False
    if re.search(pattern,"/".join(path.split('/')[-1-pattern.count('/'):]),re_flags) is None:
        return False
    else: 
        if os.path.exists(path) : return True
        else: #clean up dead directories
            del path_dict[path]
            return False

optlist, args = getopt.getopt(argv[1:], 'a',['stat','import']) 
dic_file=os.path.expanduser("~/.autojump_py")
try:
    aj_file=open(dic_file)
    path_dict=cPickle.load(aj_file)
    aj_file.close()
except IOError:
    path_dict={}

if ('-a','') in optlist:
    dicadd(path_dict," ".join(args))
    cPickle.dump(path_dict,open(dic_file,'w'),-1)
elif ('--stat','') in optlist:
    a=path_dict.items()
    a.sort(key=lambda e:e[1])
    for path,count in a[-100:]:
        print "%.1f:\t%s" % (count,path)
    print "Total key weight: %d" % sum(path_dict.values())
elif ('--import','') in optlist:
    for i in open(" ".join(args)).readlines():
        dicadd(path_dict,i[:-1])
    cPickle.dump(path_dict,open(dic_file,'w'),-1)
else:
    keyweight=sum(path_dict.values()) #Gradually forget about old directories
    if keyweight>max_keyweight:
        for k in path_dict.keys():
            path_dict[k]*=0.9*max_keyweight/keyweight
    if not args: args=['']
    dirs=path_dict.items()
    dirs.sort(key=lambda e:e[1],reverse=True)
    import re
    found=False
    for path,count in dirs:
        if match(path," ".join(args),path_dict): #First look for case-matching path
            print path
            found=True
            break
    dirs=path_dict.items() #we need to recreate the list since the first iteration potentially deletes paths
    dirs.sort(key=lambda e:e[1],reverse=True)
    if not found:
        for path,count in dirs:
            if match(path," ".join(args),path_dict,re.IGNORECASE): #Then try to ignore case
                print path
                break
    cPickle.dump(path_dict,open(dic_file+".tmp",'w'),-1)
    import shutil
    shutil.copy(dic_file+".tmp",dic_file) #cPickle.dump doesn't seem to be atomic, so this is more secure
