========
AUTOJUMP
========

----------------------------
A ``cd`` command that learns
----------------------------

One of the most used shell commands is ``cd``. A quick survey among my friends revealed that between 10 and 20% of all commands they type are actually ``cd`` commands! Unfortunately, jumping from one part of your system to another with ``cd`` requires to enter almost the full path, which isn't very practical and requires a lot of keystrokes.

autojump is a faster way to navigate your filesystem. It works by maintaining a database of the directories you use the most from the command line. The jumpstat command shows you the current contents of the database. You need to work a little bit before the database becomes usable. Once your database is reasonably complete, you can "jump" to a commonly "cd"ed directory by typing:

 j dirspec

where dirspec is a few characters of the directory you want to jump to. It will jump to the most used  directory  whose
name matches the pattern given in dirspec. Note that autojump isn't meant to be a drop-in replacement for cd, but rather a complement. Cd is fine when staying in the same area of the filesystem; autojump is there to help when you need to jump far away from your current location.

Autojump supports tab completion. Try it! Autojump should be compatible with bash 4. Please report any problems!

Pierre Gueth contributed a very nice applet for freedesktop desktops (Gnome/KDE/...). It is called "jumpapplet", try it!

Thanks to Simon Marache-Francisco's outstanding work, autojump now works perfectly with zsh.

Examples
========

::

 j mp3

could jump to ``/home/gwb/my mp3 collection``, if that is the directory in which you keep your mp3s. ::

 autojump mp3

prints out something like ``/home/gwb/my\ mp3\ collection'', but does not jump to that directory. ::

 jumpstat

will print out something along the lines of::

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
Autojump applet written by Pierre Gueth
Zsh support: Simon Marache-Francisco
Install script written by Daniel Jackoway and others.

License
=======

autojump is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

autojump is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with autojump.  If not, see <http://www.gnu.org/licenses/>.

Installation
============

Auto Installation
-----------------

run:: 

 ./install.sh 

or::
 
 ./install.zsh

depending on your shell.
Enter your root password if it asks. 

Add the line::

 source /etc/profile

to ``~/.bashrc`` or ``~/.zshrc`` if it isn't already there. 

Troubleshoot
------------

If the script fails, you may need to do::

 chmod +x install.(z)sh

before the first step. 


Manual installation of autojump is very simple: copy

- autojump to /usr/bin,
- autojump.sh to /etc/profile.d,
- autojump.1 to /usr/share/man/man1.

Make sure to source ``/etc/profile`` in your ``.bashrc`` or ``.zshrc`` ::

 source /etc/profile

Packaging
=========

For now gcarrier and I have packaged autojump for Arch Linux. It is available in [community]. To install, type::

 pacman -S autojump

Autojump is now officially a part of Debian Sid, thanks to Tanguy Ortolo’s work (for policy reasons, it requires manual activation after installing, see /usr/share/doc/autojump/README.Debian). To install, type::

 apt-get install autojump
 
Autojump is also available on the OSX Homebrew package manager::

 brew install autojump

Autojump is also packaged for a number of other distros. Check the wiki for an up-to-date list! I would be very interested by packages for other distros. If you think you can help with the packaging, please contact me!

Uninstallation
==============

To completely remove autojump you should remove these files:

``/etc/profile.d/autojump.bash``

``/etc/profile.d/autojump.sh``

``/etc/profile.d/autojump.zsh``

``/usr/bin/autojump``

``/usr/bin/jumpapplet``

``/usr/share/autojump/icon.png``

``/usr/share/autojump/``

``/usr/share/man/man1/autojump.1``

Remove any mention of autojump in your ``.bashrc`` or ``.zshrc``, then in currently running shells do:``source /etc/profile``.

If you keep getting ``autojump: command not found`` at the Bash prompt, do:``unset PROMPT_COMMAND``. You can also restart your shell.
