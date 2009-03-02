========
AUTOJUMP
========

----------------------------
A ``cd`` command that learns
----------------------------

One of the most used shell commands is ``cd``. A quick survey among my friends revealed that between 10 and 20% of all commands they type are actually ``cd`` commands! Unfortunately, jumping from one part of your system to another with ``cd`` requires to enter almost the full path, which isn't very practical and requires a lot of keystrokes.

autojump is a faster way to navigate your filesystem. It works by maintaining a database of the directories you use the most from the command line. The jumpstat command shows you the current contents of the database. You need to work a little bit  before  the  database becomes useable. Once your database is reasonably complete, you can "jump" to a directory by typing::

 j dirspec

where dirspec is a few characters of the directory you want to jump to. It will jump to the most used  directory  whose
name matches the pattern given in dirspec.

Autojump supports tab completion. Try it!

Examples
========

::

 j mp3

could jump to ``/home/gwb/my mp3 collection``, if that is the directory in which you keep your mp3s. ::

 jumpstat</b>

will print out something in the lines of::

 ...
 54.5:	/home/shared/musique
 60.0:	/home/joel/workspace/coolstuff/glandu
 83.0:	/home/joel/workspace/abs_user/autojump
 96.9:	/home/joel/workspace/autojump
 141.8:	/home/joel/workspace/vv
 161.7:	/home/joel
 Total key weight: 1077

The "key weight" reflects the amount of time you spend in a directory.

Author
======

Joel Schaerer (joel.schaerer (at) laposte.net)
Install script written by Daniel Jackoway

License
=======

autojump is distributed under the terms of the GPL, version 3.

Installation
============

Auto Installation
-----------------

run:: 

 ./install.sh 

Enter your root password if it asks. 

Add the line::

 source /etc/profile

to ``~/.bashrc`` if it isn't already there. 

Troubleshoot
------------

If the script fails, you may need to do::

 chmod +x install.sh

before the first step. 


Manual installation of autojump is very simple: copy

- autojump to /usr/bin,
- autojump.sh to /etc/profile.d,
- autojump.1 to /usr/share/man/man1.

Make sure to source ``/etc/profile`` in your ``.bashrc``::

 source /etc/profile

Packaging
=========

For now gcarrier and I have packaged autojump for Arch Linux. It is available in [community]. To install, type::

 pacman -S autojump

I would be very interested by packages for other distros. If you think you can help me with the packaging, please contact me!
