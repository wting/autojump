#!/usr/bin/env bash
# add git revision to autojump

# Fail silently if there is no git directory, ie. if the user installed from a regular download
if [[ ! -d .git ]]
then
    exit
fi

gitrevision=`git describe`
if [[ $(git diff --shortstat 2> /dev/null | tail -n1) != "" ]]; then
    gitrevision=$gitrevision"-dirty"
fi
sed -i "s/^AUTOJUMP_VERSION = \".*\"$/AUTOJUMP_VERSION = \"$gitrevision\"/" autojump
