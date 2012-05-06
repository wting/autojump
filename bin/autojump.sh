# Source autojump on BASH or ZSH depending on the shell
if [ "$BASH_VERSION" ] && [ -n "$PS1" ] && echo $SHELLOPTS | grep -v posix >>/dev/null; then
    if [ -f ~/.autojump/etc/profile.d/autojump.bash ]; then
        source ~/.autojump/etc/profile.d/autojump.bash
    elif [ -f /etc/profile.d/autojump.bash ]; then
        source /etc/profile.d/autojump.bash
    fi
elif [ "$ZSH_VERSION" ] && [ -n "$PS1" ]; then
    if [ -f ~/.autojump/etc/profile.d/autojump.zsh ]; then
        source ~/.autojump/etc/profile.d/autojump.zsh
    elif [ -f /etc/profile.d/autojump.zsh ]; then
        source /etc/profile.d/autojump.zsh
    fi
fi
