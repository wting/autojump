NAME
----

autojump - a faster way to navigate your filesystem

SYNOPSIS
--------

Jump to a previously visited directory 'foobar':

    j foo

Show all database entries and their respective key weights:

    j --stat

DESCRIPTION
-----------

autojump is a faster way to navigate your filesystem. It works by
maintaining a database of the directories you use the most from the
command line. The `j --stat` command shows you the current contents of
the database. Directories must be visited first before they can be
jumped to.

INSTALLATION
------------

### REQUIREMENTS

-   Python v2.6+
-   Bash v4.0 for tab completion (or zsh)

If you are unable to update Python to a supported version, older
versions of autojump can be
[downloaded](https://github.com/joelthelion/autojump/downloads) and
installed manually.

-   Python v2.4 is supported by [release
    v12](https://github.com/downloads/joelthelion/autojump/autojump_v12.tar.gz).

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

Please check the [Wiki](https://github.com/joelthelion/autojump/wiki)
for an up to date listing of installation methods.

### MANUAL INSTALLATION

Grab a copy of autojump:

    git clone git://github.com/joelthelion/autojump.git

Run the installation script:

    cd autojump
    ./install.sh [ --local ] [ --zsh ]

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

Unit tests are available in `./tests/`. Run unit tests with the command:

    make test

OPTIONS
-------

Options must be passed to 'autojump' and not the 'j' wrapper function.

    -a, --add DIR       manually add path to database

    --purge             deletes database entries that no longer exist on system

    -s, --stat              show database entries and their key weights

    --version           show version information and exit

INTERNAL OPTIONS
----------------

    -b, --bash          enclose directory with quotes to prevent errors

    --complete          used for tab completion

ADDITIONAL CONFIGURATION
------------------------

-   Enable ZSH Tab Completion

    ZSH tab completion requires the `compinit` module to be loaded.
    Please add the following line to your \~/.zshrc:

        autoload -U compinit; compinit

-   Always Ignore Case

    Default behavior is to prioritize exact matches over all else. For
    example, `j foo` will prefer /foobar over /FooBar even if the latter
    has a higher weight. To change this behavior and ignore case, add
    the following environmental variable in your \~/.bashrc:

        export AUTOJUMP_IGNORE_CASE=1

-   Prevent Database Entries' Decay

    Default behavior is to decay unused database entries slowly over
    time. Eventually when database limits are hit and maintenance is
    run, autojump will purge older less used entries. To prevent decay,
    add the following variable in your \~/.bashrc:

        export AUTOJUMP_KEEP_ALL_ENTRIES=1

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

ADVANCED USAGE
--------------

-   Using Multiple Arguments

    Let's assume the following database:

        30   /home/user/mail/inbox 10   /home/user/work/inbox

    `j in` would jump into /home/user/mail/inbox as the higher weighted
    entry. However you can pass multiple arguments to autojump to prefer
    a different entry. In the above example, `j w in` would then jump
    you into /home/user/work/inbox.

-   ZSH Tab Completion

    Tab completion requires two tabs before autojump will display the
    completion menu. However if `setopt nolistambiguous` is enabled,
    then only one tab is required.

-   Change Directory Weight

    To manually change a directory's key weight, you can edit the file
    *$XDG\_DATA\_HOME/autojump/autojump.txt*. Each entry has two
    columns. The first is the key weight and the second is the path:

        29.3383211216   /home/user/downloads

    All negative key weights are purged automatically.

KNOWN ISSUES
------------

-   For bash users, autojump keeps track of directories as a pre-command
    hook by modifying $PROMPT\_COMMAND. If you overwrite
    $PROMPT\_COMMAND in \~/.bashrc you can cause problems. Don't do
    this:

        export PROMPT_COMMAND="history -a"

    Do this:

        export PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND ;} history -a"

-   The jump function `j` does not support directories that begin with
    `-`. If you want to jump a directory called `--music`, try using
    `j music` instead of `j   --music`.

-   jumpapplet (bug \#59)

    Does not work in Gnome 3 shell or LDXE.

FILES
-----

If installed locally, autojump is self-contained in *\~/.autojump/*.

The database is stored in *$XDG\_DATA\_HOME/autojump/autojump.txt*.

REPORTING BUGS
--------------

For any usage related issues or feature requests please visit:

*https://github.com/joelthelion/autojump/issues*

MAILING LIST
------------

For release announcements and development related discussion please
visit:

*https://groups.google.com/forum/?fromgroups\#!forum/autojump*

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

Copyright © 2012 Free Software Foundation, Inc. License GPLv3+: GNU GPL
version 3 or later <http://gnu.org/licenses/gpl.html>. This is free
software: you are free to change and redistribute it. There is NO
WARRANTY, to the extent permitted by law.
