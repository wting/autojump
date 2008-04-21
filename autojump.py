#!/usr/bin/python
from __future__ import division
import cPickle
import getopt
from sys import argv
import os

max_keyweight=10000

def dicadd(dic,key,increment=1):
    dic[key]=dic.get(key,0.)+increment

def match(path,pattern,path_dict):
    import re
    if os.path.realpath(os.curdir)==path : return False
    if re.search(pattern,"/".join(path.split('/')[-1-pattern.count('/'):])) is None:
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
    for path,count in dirs:
        if match(path," ".join(args),path_dict):
            print path
            break
    cPickle.dump(path_dict,open(dic_file+".tmp",'w'),-1)
    import shutil
    shutil.copy(dic_file+".tmp",dic_file) #cPickle.dump doesn't seem to be atomic, so this is more secure
