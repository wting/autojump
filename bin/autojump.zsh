# set user installation paths
if [[ -d ~/.autojump/bin ]]; then
    path=(~/.autojump/bin ${path})
fi
if [[ -d ~/.autojump/functions ]]; then
    fpath=(~/.autojump/functions ${fpath})
fi


# set homebrew installation paths
if command -v brew && [[ -d "$(brew --prefix)/share/zsh/site-functions" ]]; then
    fpath=("$(brew --prefix)/share/zsh/site-functions" ${fpath})
fi


# set error file location
if [[ "$(uname)" == "Darwin" ]]; then
    export AUTOJUMP_ERROR_PATH=~/Library/autojump/errors.log
elif [[ -n "${XDG_DATA_HOME}" ]]; then
    export AUTOJUMP_ERROR_PATH="${XDG_DATA_HOME}/autojump/errors.log"
else
    export AUTOJUMP_ERROR_PATH=~/.local/share/autojump/errors.log
fi

if [[ ! -d ${AUTOJUMP_ERROR_PATH:h} ]]; then
    mkdir -p ${AUTOJUMP_ERROR_PATH:h}
fi


# change pwd hook
autojump_chpwd() {
    if [[ -f "${AUTOJUMP_ERROR_PATH}" ]]; then
        autojump --add "$(pwd)" >/dev/null 2>${AUTOJUMP_ERROR_PATH} &!
    else
        autojump --add "$(pwd)" >/dev/null &!
    fi
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
    if [[ -d "${new_path}" ]]; then
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
    if [[ -d "${new_path}" ]]; then
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
