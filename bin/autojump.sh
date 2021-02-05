# the login $SHELL isn't always the one used
# NOTE: problems might occur if /bin/sh is symlinked to /bin/bash
# Because csh is so different from sh, we cannot use the same code
echo $shell | grep -q csh && goto CSH

if [ -n "${BASH}" ]; then
    shell="bash"
elif [ -n "${ZSH_NAME}" ]; then
    shell="zsh"
elif [ -n "${__fish_datadir}" ]; then
    shell="fish"
else
    shell=$(echo ${SHELL} | awk -F/ '{ print $NF }')
fi

# prevent circular loop for sh shells
if [ "${shell}" = "sh" ]; then
    return 0

# check local install
elif [ -s ~/.autojump/share/autojump/autojump.${shell} ]; then
    source ~/.autojump/share/autojump/autojump.${shell}

# check global install
elif [ -s /usr/local/share/autojump/autojump.${shell} ]; then
    source /usr/local/share/autojump/autojump.${shell}
fi

return

# csh/tcsh jump here
CSH:

if ( -f ~/.autojump/share/autojump/autojump.tcsh ) then
    source ~/.autojump/share/autojump/autojump.tcsh
# check global install
else if ( -f /usr/local/share/autojump/autojump.tcsh ) then
    source /usr/local/share/autojump/autojump.tcsh
endif
