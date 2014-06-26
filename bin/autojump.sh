# source autojump on BASH or ZSH depending on the shell

shell=$(echo ${SHELL} | awk -F/ '{ print $NF }')

# prevent circular loop for sh shells
if [ "${shell}" = "sh" ]; then
    return 0

# check local install
elif [ -s ~/.autojump/usr/local/share/autojump/autojump.${shell} ]; then
    source ~/.autojump/usr/local/share/autojump/autojump.${shell}

# check global install
elif [ -s /usr/local/share/autojump/autojump.${shell} ]; then
    source /usr/local/share/autojump/autojump.${shell}

fi
