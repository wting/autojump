========
AUTOJUMP
========

----------------------------
A ``cd`` command that learns
----------------------------

One of the most used shell commands is ``cd``. A quick survey among my friends revealed that between 10 and 20% of all commands they type are actually ``cd`` commands! Unfortunately, jumping from one part of your system to another with ``cd`` requires to enter almost the full path, which isn't very practical and requires a lot of keystrokes.

autojump is a faster way to navigate your filesystem. It works by maintaining a database of the directories you use the most from the command line. The jumpstat command shows you the current contents of the database. You need to work a little bit before the database becomes usable. Once your database is reasonably complete, you can "jump" to a commonly used directory by typing:

 j <dir>

where <dir> is a few characters of the directory you want to jump to. It will jump to the most used  directory whose name matches the pattern given in dirspec. Note that autojump isn't meant to be a drop-in replacement for cd, but rather a complement. Cd is fine when staying in the same area of the filesystem; autojump is there to help when you need to jump far away from your current location.

Autojump supports tab completion starting with bash v4.0+.

Pierre Gueth contributed a very nice applet for freedesktop desktops (Gnome/KDE/...). It is called "jumpapplet", try it!

Thanks to Simon Marache-Francisco's outstanding work, autojump now works perfectly with zsh.

Usage Examples
==============

::

 j music

would jump to ``/home/user/music/``, if that's a commonly directory traversed by command line. ::

 autojump music

displays the directory autojump would jump to if invoked. ::

 jumpstat

displays a listing of tracked directories and their respective weights. For example: ::

 ...
 54.5:	/home/shared/misc
 60.0:	/home/user/Dropbox
 96.9:	/home/user/code/autojump
 161.7:	/home/user
 Total key weight: 1077

The "key weight" reflects the amount of time you spend in a directory.

Authors
=======

- Joel Schaerer (joel.schaerer (at) laposte.net)
- autojump applet: Pierre Gueth
- zsh support: Simon Marache-Francisco, William Ting
- installation: Daniel Jackoway, William Ting, and others.

License
=======

autojump is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

autojump is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with autojump.  If not, see <http://www.gnu.org/licenses/>.

Requirements
============

Python v2.6+ or 3.0+

Installation
============

Automatic Installation
----------------------

**Linux**

autojump is included in the following distro repositories, please use relevant package management utilities to install (e.g. yum, apt-get, etc):

- Debian testing/unstable, Ubuntu, Linux Mint

  On Debian only, autojump requires manual activation for policy reasons. Please see ``/usr/share/doc/autojump/README.Debian``.

- RedHat, Fedora, CentOS
- ArchLinux
- Gentoo
- Frugalware
- Slackware

**Mac**

- Homebrew

 ``brew install autojump``

- `Macports <https://trac.macports.org/browser/trunk/dports/sysutils/autojump/Portfile>`_

Manual Installation
-------------------

Grab a copy of autojump::

 git clone git://github.com/joelthelion/autojump.git

Run the installation script::

 cd autojump
 ./install.sh [ --local ] [ --zsh ]

and follow on screen instructions.

Use --local to install into current user's home directory.

Use --zsh to install for Z shell.

Manual Uninstallation
=====================

It is recommended to use your distribution's relevant package management utilities, unless you installed manually or ran into uninstallation issues.

Grab a copy of autojump::

 git clone git://github.com/joelthelion/autojump.git

Run the uninstallation script::

 cd autojump
 ./uninstall.sh

and follow on screen instructions.

If you keep getting ``autojump: command not found`` at the Bash prompt, do:``unset PROMPT_COMMAND``. You can also restart your shell.
