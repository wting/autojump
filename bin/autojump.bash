# set user installation paths
if [[ -d ~/.autojump/ ]]; then
    export PATH=~/.autojump/bin:"${PATH}"
fi


# set error file location
if [[ "$(uname)" == "Darwin" ]]; then
    export AUTOJUMP_ERROR_PATH=~/Library/autojump/errors.log
elif [[ -n "${XDG_DATA_HOME}" ]]; then
    export AUTOJUMP_ERROR_PATH="${XDG_DATA_HOME}/autojump/errors.log"
else
    export AUTOJUMP_ERROR_PATH=~/.local/share/autojump/errors.log
fi

if [[ ! -d "$(dirname ${AUTOJUMP_ERROR_PATH})" ]]; then
    mkdir -p "$(dirname ${AUTOJUMP_ERROR_PATH})"
fi


# enable tab completion
_autojump() {
        local cur
        cur=${COMP_WORDS[*]:1}
        comps=$(autojump --complete $cur)
        while read i; do
            COMPREPLY=("${COMPREPLY[@]}" "${i}")
        done <<EOF
        $comps
EOF
}
complete -F _autojump j jo

_complete_autojump_c() {
  local current_word
  SAVE_IFS=$IFS
  IFS=$'\n'
  COMPREPLY=()
  current_word="${COMP_WORDS[COMP_CWORD]}"
  # tabbing on empty "prefix", e.g. jc <tab>
  if [ -z "$current_word" ]; then
    autocomplete_pattern="$PWD"
  # tabbing when last item is a number, e.g. jc /some/path.*first.*second__2<tab>
  elif [[ "$current_word" =~ ^[0-9]+$ ]]; then
    autocomplete_pattern="${PWD}__$current_word"
  # tabbing when last item contains .*, e.g. jc /some/path.*another<tab>
  elif [[ "$current_word" =~ .*\.\*.* ]]; then
    autocomplete_pattern="$current_word"
  # tabbing when there are tokens, e.g. jc first second<tab>
  else
    autocomplete_pattern="${PWD}.*${current_word}"
  fi
  comps=$(autojump --complete "$autocomplete_pattern")
  COMPREPLY=($(compgen -W "$comps" --))
  IFS=$SAVE_IFS
}
complete -F _complete_autojump_c jc jco

# change pwd hook
autojump_add_to_database() {
    if [[ -f "${AUTOJUMP_ERROR_PATH}" ]]; then
        (autojump --add "$(pwd)" >/dev/null 2>>${AUTOJUMP_ERROR_PATH} &) &>/dev/null
    else
        (autojump --add "$(pwd)" >/dev/null &) &>/dev/null
    fi
}

case $PROMPT_COMMAND in
    *autojump*)
        ;;
    *)
        PROMPT_COMMAND="${PROMPT_COMMAND:+$(echo "${PROMPT_COMMAND}" | awk '{gsub(/; *$/,"")}1') ; }autojump_add_to_database"
        ;;
esac


# default autojump command
j() {
    if [[ ${@} =~ ^-{1,2}.* ]]; then
        autojump ${@}
        return
    fi

    new_path="$(autojump ${@})"
    if [[ -d "${new_path}" ]]; then
        echo -e "\\033[31m${new_path}\\033[0m"
        cd "${new_path}"
    else
        echo "autojump: directory '${@}' not found"
        echo "Try \`autojump --help\` for more information."
        false
    fi
}


alias jc=j


# open autojump results in file browser
jo() {
    if [[ ${@} == -* ]]; then
        autojump ${@}
        return
    fi

    new_path="$(autojump ${@})"
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


alias jco=jo
