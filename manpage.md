% autojump(1) release-v19
%
% 07 April 2012

## NAME

autojump - a faster way to navigate your filesystem

## SYNOPSIS
Jump to a previously visited directory 'foobar':

    j foo

Show all database entries and their respective key weights:

    jumpstat

## DESCRIPTION

autojump is a faster way to navigate your filesystem. It works by maintaining a database of the directories you use the most from the command line. The jumpstat command shows you the current contents of the database. Directories must be visited first before they can be jumped to.

autojump supports tab completion in Bash v4.0+.

## OPTIONS

Below options must be passed to 'autojump' and not the 'j' wrapper function.

    -a, --add DIR       manually add path to database

    --stat              show database entries and their key weights

    --version           show version information and exit

## INTERNAL OPTIONS

    -b, --bash

    --completion        prevent key weight decay over time

## ADVANCED USAGE

To manually change an entry's weight, edit the file $XDG_DATA_HOME/autojump/autojump.txt.

## FILES

If installed locally, autojump is self-contained in the directory ~/.autojump/.

The database is stored in $XDG_DATA_HOME/autojump/autojump.txt.

## REPORTING BUGS

For any issues please visit the following URL:

https://github.com/joelthelion/autojump/issues

## THANKS

Special thanks goes out to: Pierre Gueth, Simon Marache-Francisco, Daniel Jackoway, and many others.

## AUTHORS

autojump was originally written by Joël Schaerer, and currently maintained by William Ting.

## COPYRIGHT

Copyright © 2012 Free Software Foundation, Inc. License GPLv3+: GNU  GPL version 3 or later <http://gnu.org/licenses/gpl.html>. This is free software: you are free to change and redistribute it. There is NO WARRANTY, to the extent permitted by law.
