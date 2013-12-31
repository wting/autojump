_autojump() {
        local cur
        cur=${COMP_WORDS[*]:1}
        comps=$(autojump --complete $cur)
        while read i
        do
            COMPREPLY=("${COMPREPLY[@]}" "${i}")
        done <<EOF
        $comps
EOF
}
complete -F _autojump j

_autojump_files() {
    if [[ ${COMP_WORDS[COMP_CWORD]} == *__* ]]; then
        local cur
        #cur=${COMP_WORDS[*]:1}
        cur=${COMP_WORDS[COMP_CWORD]}
        comps=$(autojump --complete $cur)
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

# set paths if necessary for local installations
if [ -d ~/.autojump/ ]; then
    export PATH=~/.autojump/bin:"${PATH}"
fi

autojump_add_to_database() {
    autojump -a "$(pwd)" &>/dev/null
}

case $PROMPT_COMMAND in
    *autojump*)
        ;;
    *)
        PROMPT_COMMAND="${PROMPT_COMMAND:+$(echo "${PROMPT_COMMAND}" | awk '{gsub(/; *$/,"")}1') ; }autojump_add_to_database"
        ;;
esac

j() {
    if [[ ${@} =~ ^-{1,2}.* ]]; then
        autojump ${@}
        return
    fi

    new_path="$(autojump ${@})"
    if [ -d "${new_path}" ]; then
        echo -e "\\033[31m${new_path}\\033[0m"
        cd "${new_path}"
    else
        echo "autojump: directory '${@}' not found"
        echo "Try \`autojump --help\` for more information."
        false
    fi
}

jc() {
    if [[ ${@} == -* ]]; then
        autojump ${@}
    else
        j $(pwd)/ ${@}
    fi
}

jo() {
    if [ -z $(autojump $@) ]; then
        echo "autojump: directory '${@}' not found"
        echo "Try \`autojump --help\` for more information."
        false
    else
        case ${OSTYPE} in
            linux-gnu)
                xdg-open "$(autojump $@)"
                ;;
            darwin*)
                open "$(autojump $@)"
                ;;
            cygwin)
                cygstart "" $(cygpath -w -a $(pwd))
                ;;
            *)
                echo "Unknown operating system." 1>&2
                ;;
        esac
    fi
}

jco() {
    if [[ ${@} == -* ]]; then
        autojump ${@}
    else
        jo $(pwd) ${@}
    fi
}
