#!/usr/bin/env bash
if [ -d .git ];
then
	# add git revision to autojump
	gitrevision=`git describe`
	if [[ $(git diff --shortstat 2> /dev/null | tail -n1) != "" ]]; then
		gitrevision=$gitrevision"-dirty"
	fi
	sed -e "s/^AUTOJUMP_VERSION = \".*\"$/AUTOJUMP_VERSION = \"git revision $gitrevision\"/" autojump.py > autojump
else
	cp autojump.py autojump
fi
	chmod a+rx autojump
