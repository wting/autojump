"""
IPython autojump magic

Written by keith hughitt <keith.hughitt@gmail.com>, based on an earlier
version by Mario Pastorelli <pastorelli.mario@gmail.com>.

To install, `create a new IPython user profile <http://ipython.org/ipython-doc/stable/config/ipython.html#configuring-ipython>`_
if you have not already done so by running:

    ipython profile create
    
And copy this file into the "startup" folder of your new profile (e.g. 
"$HOME/.config/ipython/profile_default/startup/").

@TODO: extend %cd to call "autojump -a"
"""
import os
import subprocess as sub
from IPython.core.magic import (register_line_magic, register_cell_magic,
                                register_line_cell_magic)

ip = get_ipython()

@register_line_magic
def j(path):
    cmd = ['autojump'] + path.split()
    newpath = sub.Popen(cmd, stdout=sub.PIPE, shell=False).communicate()[0][:-1] # delete last '\n'
    if newpath:
        ip.magic('cd %s' % newpath)

# remove from namespace
del j
