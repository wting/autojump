NAME
----

autojump - a faster way to navigate your filesystem

SYNOPSIS
--------

Jump to a previously visited directory that contains 'foo':

    j foo

Jump to a previously visited subdirectory of the current directory:

    jc bar

Show database entries and their respective key weights:

    j --stat

DESCRIPTION
-----------

autojump is a faster way to navigate your filesystem. It works by
maintaining a database of the directories you use the most from the
command line. Directories must be visited first before they can be
jumped to.

INSTALLATION
------------

### REQUIREMENTS

-   Python v2.6+
-   Bash v4.0 for tab completion (or zsh)

If you are unable to update Python to a supported version, older
versions of autojump can be [downloaded][dl] and installed manually.

-   Python v2.4 is supported by [release v12][v12].

### AUTOMATIC INSTALLATION

**Linux**

autojump is included in the following distro repositories, please use
relevant package management utilities to install (e.g. yum, apt-get,
etc):

-   Debian\* testing/unstable, Ubuntu, Linux Mint
-   RedHat, Fedora, CentOS
-   ArchLinux
-   Gentoo
-   Frugalware
-   Slackware

\* Requires manual activation for policy reasons, please see
`/usr/share/doc/autojump/README.Debian`.

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
    ./install.sh [ --local ]

and follow on screen instructions.

### MANUAL UNINSTALLATION

It is recommended to use your distribution's relevant package management
utilities, unless you installed manually or ran into uninstallation
issues.

Grab a copy of autojump:

    git clone git://github.com/joelthelion/autojump.git

Run the uninstallation script:

    cd autojump
    ./uninstall.sh

and follow on screen instructions.

If you keep getting `autojump: command not found` at the prompt,
do:`unset PROMPT_COMMAND`. You can also restart your shell.

DEVELOPMENT
-----------

The source code is primarily in `./bin/autojump`. Various shell wrapper
scripts are also available in `./bin/`.

Documentation is in various files under `./docs/`. Build documentation
with the command:

    make docs

Tests are available in `./tests/` and require Python 3.3 or Python 2.7 with
[mock][mock]. Run unit tests with the command:

    make test

OPTIONS
-------

Options must be passed to 'autojump' and not the 'j' wrapper function.

    -i, --increase      manually increase current directory weight

    -d, --decrease      manually decrease current directory weight

    --purge             deletes database entries that no longer exist on system

    -s, --stat          show general stats and top 100 database entries

    --version           show version information and exit

ADVANCED USAGE
--------------

-   Using Multiple Arguments

    Let's assume the following database:

        30   /home/user/mail/inbox
        10   /home/user/work/inbox

    `j in` would jump into /home/user/mail/inbox as the higher weighted
    entry. However you can pass multiple arguments to autojump to prefer
    a different entry. In the above example, `j w in` would then jump
    you into /home/user/work/inbox.

-   Jump To A Child Directory.

    Sometimes it's convenient to jump to a child directory
    (sub-directory of current directory) rather than typing out the full
    name.

        jc images

-   Open File Manager To Directories (instead of jumping)

    Instead of jumping to a directory, you can open a file explorer
    window (Mac Finder, Windows Explorer, GNOME Nautilus, etc) to the
    directory instead.

        jo music

    Opening a file manager to a child directory is also supported.

        jco images

ADDITIONAL CONFIGURATION
------------------------

-   Enable ZSH Tab Completion

    ZSH tab completion requires the `compinit` module to be loaded.
    Please add the following line to your \~/.zshrc *after* loading
    autojump:

        autoload -U compinit && compinit

    For security compinit checks completion system if files will be
    owned by root or the current user. This check can be ignored by
    using the -u flag:

        autoload -U compinit && compinit -u

    Tab completion requires two tabs before autojump will display the
    completion menu. However if `setopt nolistambiguous` is enabled,
    then only one tab is required.

-   Always Ignore Case

    Default behavior is to prioritize exact matches over all else. For
    example, `j foo` will prefer /foobar over /FooBar even if the latter
    has a higher weight. To change this behavior and ignore case, add
    the following environmental variable in your \~/.bashrc:

        export AUTOJUMP_IGNORE_CASE=1

-   Prefer Symbolic Links

    Default behavior is to evaluate symbolic links into full paths as to
    reduce duplicate entries in the database. However, some users prefer
    a shorter working directory path in their shell prompt. To switch
    behavior to prefer symbolic links, add the following environmental
    variable in your \~/.bashrc:

        export AUTOJUMP_KEEP_SYMLINKS=1

-   Autocomplete Additional Commands (Bash only)

    Autojump can be used to autocomplete other commands (e.g. cp or
    vim). To use this feature, add the following environmental variable
    in your \~/.bashrc:

        export AUTOJUMP_AUTOCOMPLETE_CMDS='cp vim'

    Changes require reloading autojump to take into effect.

KNOWN ISSUES
------------

-   For bash users, autojump keeps track of directories as a pre-command
    hook by modifying \$PROMPT\_COMMAND. If you overwrite
    \$PROMPT\_COMMAND in \~/.bashrc you can cause problems. Don't do
    this:

        export PROMPT_COMMAND="history -a"

    Do this:

        export PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND ;} history -a"

-   The jump function `j` does not support directories that begin with
    `-`. If you want to jump a directory called `--music`, try using
    `j music` instead of `j   --music`.

FILES
-----

If installed locally, autojump is self-contained in *\~/.autojump/*.

The database is stored in *\$XDG\_DATA\_HOME/autojump/autojump.txt*.

REPORTING BUGS
--------------

For any usage related issues or feature requests please visit:

*https://github.com/joelthelion/autojump/issues*

THANKS
------

Special thanks goes out to: Pierre Gueth, Simon Marache-Francisco,
Daniel Jackoway, and many others.

AUTHORS
-------

autojump was originally written by Joël Schaerer, and currently
maintained by William Ting.

COPYRIGHT
---------

Copyright © 2013 Free Software Foundation, Inc. License GPLv3+: GNU GPL
version 3 or later <http://gnu.org/licenses/gpl.html>. This is free
software: you are free to change and redistribute it. There is NO
WARRANTY, to the extent permitted by law.

[dl]: https://github.com/joelthelion/autojump/downloads
[mock]: https://pypi.python.org/pypi/mock
[v12]: https://github.com/downloads/joelthelion/autojump/autojump_v12.tar.gz
[wiki]: https://github.com/joelthelion/autojump/wiki
