#Source autojump.bashrc only if we're on bash, as it is
#not compatible with other shells
if [ $SHELL = "/bin/bash" ] && [ -n "$PS1" ]; then
	source /etc/profile.d/autojump.bash
fi
