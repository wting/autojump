## NAME

autojump - a faster way to navigate your filesystem

## SYNOPSIS
Jump to a previously visited directory 'foobar':

    j foo

Show all database entries and their respective key weights:

    j --stat

## DESCRIPTION

autojump is a faster way to navigate your filesystem. It works by maintaining a
database of the directories you use the most from the command line. The `j
--stat` command shows you the current contents of the database. Directories must
be visited first before they can be jumped to.
