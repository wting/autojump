#!/usr/bin/env bash
# add git revision to autojump

# Fail silently if there is no git directory, ie. if the user installed from a regular download
if [[ ! -d .git ]]; then
    exit
fi

if [ -z "$1" ]; then
    gitrevision=`git describe`
    if [[ $(git diff --shortstat 2> /dev/null | tail -n1) != "" ]]; then
        gitrevision=$gitrevision"-dirty"
    fi
else
    gitrevision="$1"
fi

sed -i "s/^VERSION = \".*\"$/VERSION = \"$gitrevision\"/" ./bin/autojump
