_autojump()
{
        local cur
        cur=${COMP_WORDS[*]:1}
        comps=$(autojump --bash --complete $cur)
        while read i
        do
            COMPREPLY=("${COMPREPLY[@]}" "${i}")
        done <<EOF
        $comps
EOF
}
complete -F _autojump j

_autojump_files()
{
    if [[ ${COMP_WORDS[COMP_CWORD]} == *__* ]]; then
        local cur
        #cur=${COMP_WORDS[*]:1}
        cur=${COMP_WORDS[COMP_CWORD]}
        comps=$(autojump --bash --complete $cur)
        while read i
        do
            COMPREPLY=("${COMPREPLY[@]}" "${i}")
        done <<EOF
        $comps
EOF
    fi
}

if [[ -n ${AUTOJUMP_AUTOCOMPLETE_CMDS} ]]; then
    complete -o default -o bashdefault -F _autojump_files ${AUTOJUMP_AUTOCOMPLETE_CMDS}
fi

#determine the data directory according to the XDG Base Directory Specification
if [[ -n ${XDG_DATA_HOME} ]] && [[ ${XDG_DATA_HOME} =~ ${USER} ]]; then
    export AUTOJUMP_DATA_DIR="${XDG_DATA_HOME}/autojump"
else
    export AUTOJUMP_DATA_DIR=~/.local/share/autojump
fi

if [ ! -e "${AUTOJUMP_DATA_DIR}" ]; then
    mkdir -p "${AUTOJUMP_DATA_DIR}"
    mv ~/.autojump_py "${AUTOJUMP_DATA_DIR}/autojump_py" 2>>/dev/null #migration
    mv ~/.autojump_py.bak "${AUTOJUMP_DATA_DIR}/autojump_py.bak" 2>>/dev/null
    mv ~/.autojump_errors "${AUTOJUMP_DATA_DIR}/autojump_errors" 2>>/dev/null
fi

# set paths if necessary for local installations
if [ -d ~/.autojump/ ]; then
    export PATH=~/.autojump/bin:"${PATH}"
fi

export AUTOJUMP_HOME=${HOME}
if [ "${AUTOJUMP_KEEP_SYMLINKS}" == "1" ]; then
    _PWD_ARGS=""
else
    _PWD_ARGS="-P"
fi

autojump_add_to_database() {
    if [[ "${AUTOJUMP_HOME}" == "${HOME}" ]]; then
        autojump -a "$(pwd ${_PWD_ARGS})" 1>/dev/null 2>>"${AUTOJUMP_DATA_DIR}/.autojump_errors"
    fi
}

case $PROMPT_COMMAND in
    *autojump*)    ;;
    *)   export PROMPT_COMMAND="autojump_add_to_database; ${PROMPT_COMMAND:-:}";;
esac

function j {
    if [[ ${@} =~ ^-{1,2}.* ]]; then
        autojump ${@}
        return
    fi

    new_path="$(autojump $@)"
    if [ -d "${new_path}" ]; then
        echo -e "\\033[31m${new_path}\\033[0m"
        cd "${new_path}"
    else
        echo "autojump: directory '${@}' not found"
        echo "Try \`autojump --help\` for more information."
        false
    fi
}
