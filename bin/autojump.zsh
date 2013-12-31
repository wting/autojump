# set paths for user installations
if [[ -d ${HOME}/.autojump ]]; then
    path=(${HOME}/.autojump/bin ${path})
    fpath=(${HOME}/.autojump/functions/ ${fpath})
fi

# set fpath if necessary for homebrew installation
command -v brew &>/dev/null \
    && [[ -d "`brew --prefix`/share/zsh/site-functions" ]] \
    && fpath=(`brew --prefix`/share/zsh/site-functions ${fpath})

# add change pwd hook
autojump_chpwd() {
    (autojump -a "$(pwd)" &) &>/dev/null
}

typeset -gaU chpwd_functions
chpwd_functions+=autojump_chpwd

# default autojump command
j() {
    if [[ ${@} == -* ]]; then
        autojump ${@}
        return
    fi

    local new_path="$(autojump ${@})"
    if [ -d "${new_path}" ]; then
        echo -e "\\033[31m${new_path}\\033[0m"
        cd "${new_path}"
    else
        echo "autojump: directory '${@}' not found"
        echo "Try \`autojump --help\` for more information."
        false
    fi
}

# jump to child directory (subdirectory of current path)
jc() {
    if [[ ${@} == -* ]]; then
        autojump ${@}
    else
        j $(pwd) ${@}
    fi
}

# open autojump results in file browser
jo() {
    if [[ ${@} == -* ]]; then
        autojump ${@}
        return
    fi

    local new_path="$(autojump ${@})"
    if [ -d "${new_path}" ]; then
        case ${OSTYPE} in
            linux-gnu)
                xdg-open "${new_path}"
                ;;
            darwin*)
                open "${new_path}"
                ;;
            cygwin)
                cygstart "" $(cygpath -w -a ${new_path})
                ;;
            *)
                echo "Unknown operating system." 1>&2
                ;;
        esac
    else
        echo "autojump: directory '${@}' not found"
        echo "Try \`autojump --help\` for more information."
        false
    fi
}

# open autojump results (child directory) in file browser
jco() {
    if [[ ${@} == -* ]]; then
        autojump ${@}
    else
        jo $(pwd) ${@}
    fi
}
