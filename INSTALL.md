## INSTALLATION

### REQUIREMENTS

Python v2.7+ or 3.2+

Bash v4.0+ for tab completion

### AUTOMATIC INSTALLATION

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

Homebrew is the recommended installation method for Mac OS X::

    brew install autojump

A MacPorts installation method is also [available](https://trac.macports.org/browser/trunk/dports/sysutils/autojump/Portfile).

**Other**

Please check the [Wiki](https://github.com/joelthelion/autojump/wiki) for an up to date listing of installation methods.

### MANUAL INSTALLATION

Grab a copy of autojump::

    git clone git://github.com/joelthelion/autojump.git

Run the installation script::

    cd autojump
    ./install.sh [ --local ] [ --zsh ]

and follow on screen instructions.

### MANUAL UNINSTALLATION

It is recommended to use your distribution's relevant package management utilities, unless you installed manually or ran into uninstallation issues.

Grab a copy of autojump:

    git clone git://github.com/joelthelion/autojump.git

Run the uninstallation script:

    cd autojump
    ./uninstall.sh

and follow on screen instructions.

If you keep getting `autojump: command not found` at the prompt, do:`unset PROMPT_COMMAND`. You can also restart your shell.
