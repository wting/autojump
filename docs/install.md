## INSTALLATION

### REQUIREMENTS

Python v2.7+ or 3.2+

Bash v4.0+ for tab completion

If you are unable to update Python to a supported version, older versions of autojump can be [downloaded][dl] and installed manually.

Python v2.6+ is supported by [release v19][v19].

Python v2.4+ is supported by [release v12][v12].

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

Homebrew is the recommended installation method for Mac OS X:

    brew install autojump

MacPorts also available:

    port install autojump

**Other**

Please check the [Wiki][wiki] for an up to date listing of installation methods.

### MANUAL INSTALLATION

Grab a copy of autojump:

    git clone git://github.com/joelthelion/autojump.git

Run the installation script:

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

[dl]: https://github.com/joelthelion/autojump/downloads
[v12]: https://github.com/downloads/joelthelion/autojump/autojump_v12.tar.gz
[v19]: https://github.com/downloads/joelthelion/autojump/autojump_v19.tar.gz
[wiki]: https://github.com/joelthelion/autojump/wiki
