# determine the data directory according to the XDG Base Directory Specification
autoload -U is-at-least

export AUTOJUMP_DATA_DIR=${HOME}/.local/share/autojump
if is-at-least 4.3.5; then
	if [[ -n ${XDG_DATA_HOME} ]] && [[ ${XDG_DATA_HOME} =~ ${USER} ]]; then
		export AUTOJUMP_DATA_DIR="${XDG_DATA_HOME}/autojump"
	fi
else
	if [[ -n ${XDG_DATA_HOME} ]] && [[ ${XDG_DATA_HOME} -pcre-match ${USER} ]]; then
		export AUTOJUMP_DATA_DIR="${XDG_DATA_HOME}/autojump"
	fi
fi

if [[ ! -e ${AUTOJUMP_DATA_DIR} ]]; then
    mkdir -p "${AUTOJUMP_DATA_DIR}"
    mv ${HOME}/.autojump_py "${AUTOJUMP_DATA_DIR}/autojump_py" 2>>/dev/null #migration
    mv ${HOME}/.autojump_py.bak "${AUTOJUMP_DATA_DIR}/autojump_py.bak" 2>>/dev/null
    mv ${HOME}/.autojump_errors "${AUTOJUMP_DATA_DIR}/autojump_errors" 2>>/dev/null
fi

# set paths if necessary for local installations
if [[ -d ${HOME}/.autojump ]]; then
    path=(${HOME}/.autojump/bin ${path})
    fpath=(${HOME}/.autojump/functions/ ${fpath})
fi
# set fpath if necessary for homebrew installation
if [[ -d "`brew --prefix 2>/dev/null`/share/zsh/functions" ]]; then
    fpath=(`brew --prefix`/share/zsh/functions ${fpath})
fi

function autojump_preexec() {
    if [[ "${AUTOJUMP_KEEP_SYMLINKS}" == "1" ]]; then
        _PWD_ARGS=""
    else
        _PWD_ARGS="-P"
    fi
    { (autojump -a "$(pwd ${_PWD_ARGS})"&)>/dev/null 2>>|${AUTOJUMP_DATA_DIR}/.autojump_errors ; } 2>/dev/null
}

typeset -ga preexec_functions
preexec_functions+=autojump_preexec

function j {
    if is-at-least 4.3.5; then
        if [[ ${@} =~ -.* ]]; then
            autojump ${@}
            return
        fi
    else
        if [[ ${@} -pcre-match -.* ]]; then
            autojump ${@}
            return
        fi
    fi

    local new_path="$(autojump $@)"
    if [ -d "${new_path}" ]; then
        echo -e "\\033[31m${new_path}\\033[0m"
        cd "${new_path}"
    else
        echo "autojump: directory '${@}' not found"
        echo "Try \`autojump --help\` for more information."
        false
    fi
}
