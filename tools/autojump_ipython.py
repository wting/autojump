# This module was contributed by Mario Pastorelli <pastorelli.mario@gmail.com>
# It is released in the public domain

# This tool provides "j" for ipython
# To use it, copy it in your ~/.ipython directory
# and add the following line to ipy_user_conf.py:
# import autojump_ipython

import os
import subprocess as sub
from IPython.ipapi import get
from IPython.iplib import InteractiveShell

ip = get()


def magic_j(self, parameter_s=''):
    cmd = ['autojump'] + parameter_s.split()
    # print 'executing autojump with args %s' % str(cmd)
    newpath = sub.Popen(cmd, stdout=sub.PIPE, shell=False).communicate(
    )[0][:-1]  # delete last '\n'
    # print 'Autojump answer: \'%s\'' % newpath
    if newpath:
        ip.magic('cd \'%s\'' % newpath)


def cd_decorator(f):
    def autojump_cd_monitor(self, parameter_s=''):
        f(self, parameter_s)
        sub.call(['autojump', '-a', os.getcwd()])
    return autojump_cd_monitor

# Add the new magic function to the class dict and decorate magic_cd:
InteractiveShell.magic_j = magic_j
InteractiveShell.magic_cd = cd_decorator(InteractiveShell.magic_cd)

# And remove the global name to keep global namespace clean.
del magic_j
del cd_decorator
