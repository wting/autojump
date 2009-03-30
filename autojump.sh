# Source autojump on BASH or ZSH depending on the shell
if [ "$BASH_VERSION" ] && [ -n "$PS1" ] && echo $SHELLOPTS | grep -v posix >>/dev/null; then
	. /etc/profile.d/autojump.bash
elif [ "$ZSH_VERSION" ] && [ -n "$PS1" ]; then
    . /etc/profile.d/autojump.zsh
fi
