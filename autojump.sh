#Source autojump.bashrc only if we're on bash, as it is
#not compatible with other shells
if [ "$BASH_VERSION" ] && [ -n "$PS1" ] && echo $SHELLOPTS | grep -v posix >>/dev/null; then
	. /etc/profile.d/autojump.bash
fi
