# This module was contributed by Mario Pastorelli <pastorelli.mario@gmail.com>
# It is released in the public domain

import os
import subprocess as sub
from IPython.ipapi import get
from IPython.iplib import InteractiveShell

# Export the environment variable pointing to the autojump storage dir
ip = get()
ip.magic('env AUTOJUMP_DATA_DIR=/home/rief/.local/share/autojump')

def magic_j(self,parameter_s=''):
    cmd = ['autojump']+parameter_s.split()
#    print 'executing autojump with args %s' % str(cmd)
    newpath=sub.Popen(cmd,stdout=sub.PIPE,shell=False).communicate()[0][:-1] # delete last '\n'
#    print 'Autojump answer: \'%s\'' % newpath
    ip.magic('cd \'%s\'' % newpath)

def cd_decorator(f):
    def autojump_cd_monitor(self,parameter_s=''):
        f(self,parameter_s)
#        print 'Calling autojump -a '+str(parameter_s.split())
        sub.call(['autojump','-a']+parameter_s.split())
    return autojump_cd_monitor

# Add the new magic function to the class dict and decorate magic_cd:
InteractiveShell.magic_j = magic_j
InteractiveShell.magic_cd = cd_decorator(InteractiveShell.magic_cd)

# And remove the global name to keep global namespace clean.
del magic_j
del cd_decorator
