# the login $SHELL isn't always the one used
# NOTE: problems might occur if /bin/sh is symlinked to /bin/bash
if [ -n "${BASH}" ]; then
    shell="bash"
elif [ -n "${ZSH_NAME}" ]; then
    shell="zsh"
elif [ -n "${__fish_datadir}" ]; then
    shell="fish"
elif [ -n "${version}" ]; then
    shell="tcsh"
else
    shell=$(echo ${SHELL} | awk -F/ '{ print $NF }')
fi

# Support git-bash (msysgit)
if [[ "${OS}" =~ Windows ]]; then
    local_autojump_dir="${LOCALAPPDATA}/autojump"
else
    local_autojump_dir="~/.autojump"
fi

# prevent circular loop for sh shells
if [ "${shell}" = "sh" ]; then
    return 0

# check local install
elif [ -s "${local_autojump_dir}/share/autojump/autojump.${shell}" ]; then
    source "${local_autojump_dir}/share/autojump/autojump.${shell}"

# check global install
elif [ -s /usr/local/share/autojump/autojump.${shell} ]; then
    source /usr/local/share/autojump/autojump.${shell}
fi
