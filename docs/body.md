## OPTIONS

Options must be passed to 'autojump' and not the 'j' wrapper function.

    -a, --add DIR       manually add path to database

    --purge             deletes database entries that no longer exist on system

    -s, --stat              show database entries and their key weights

    --version           show version information and exit

## INTERNAL OPTIONS

    -b, --bash          enclose directory with quotes to prevent errors

    --complete          used for tab completion

## ADDITIONAL CONFIGURATION

- Always Ignore Case

    Default behavior is to prioritize exact matches over all else. For example, `j foo` will prefer /foobar over /FooBar even if the latter has a higher weight. To change this behavior and ignore case, add the following environmental variable in your ~/.bashrc:

        export AUTOJUMP_IGNORE_CASE=1

- Prevent Database Entries' Decay

    Default behavior is to decay unused database entries slowly over time. Eventually when database limits are hit and maintenance is run, autojump will purge older less used entries. To prevent decay, add the following variable in your ~/.bashrc:

        export AUTOJUMP_KEEP_ALL_ENTRIES=1

- Prefer Symbolic Links

    Default behavior is to evaluate symbolic links into full paths as to reduce duplicate entries in the database. However, some users prefer a shorter working directory path in their shell prompt. To switch behavior to prefer symbolic links, add the following environmental variable in your ~/.bashrc:

        export AUTOJUMP_KEEP_SYMLINKS=1

## ADVANCED USAGE

- Change Directory Weight

    To manually change a directory's key weight, you can edit the file _$XDG_DATA_HOME/autojump/autojump.txt_. Each entry has two columns. The first is the key weight and the second is the path:

        29.3383211216   /home/user/downloads

    All negative key weights are purged automatically.

## KNOWN ISSUES

- The jump function `j` does not support directories that begin with `-`. If you want to jump a directory called `--music`, try using `j music` instead of `j --music`.

- zsh (bug #86)

    Tab completion does not work.

- jumpapplet (bug #59)

    Does not work in Gnome 3 shell or LDXE.

## FILES

If installed locally, autojump is self-contained in _~/.autojump/_.

The database is stored in _$XDG_DATA_HOME/autojump/autojump.txt_.

## REPORTING BUGS

For any usage related issues or feature requests please visit:

_https://github.com/joelthelion/autojump/issues_

## MAILING LIST

For release announcements and development related discussion please visit:

_https://groups.google.com/forum/?fromgroups#!forum/autojump_

## THANKS

Special thanks goes out to: Pierre Gueth, Simon Marache-Francisco, Daniel Jackoway, and many others.

## AUTHORS

autojump was originally written by Joël Schaerer, and currently maintained by William Ting.

## COPYRIGHT

Copyright © 2012 Free Software Foundation, Inc. License GPLv3+: GNU  GPL version 3 or later <http://gnu.org/licenses/gpl.html>. This is free software: you are free to change and redistribute it. There is NO WARRANTY, to the extent permitted by law.
