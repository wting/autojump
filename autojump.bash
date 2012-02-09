#Copyright Joel Schaerer 2008, 2009
#This file is part of autojump

#autojump is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, either version 3 of the License, or
#(at your option) any later version.
#
#autojump is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#
#You should have received a copy of the GNU General Public License
#along with autojump.  If not, see <http://www.gnu.org/licenses/>.

#This shell snippet sets the prompt command and the necessary aliases
_autojump()
{
        local cur
        cur=${COMP_WORDS[*]:1}
        comps=$(autojump --bash --completion $cur)
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
        comps=$(autojump --bash --completion $cur)
        while read i
        do
            COMPREPLY=("${COMPREPLY[@]}" "${i}")
        done <<EOF
        $comps
EOF
    fi
}
complete -o default -o bashdefault -F _autojump_files cp mv meld diff kdiff3

#determine the data directory according to the XDG Base Directory Specification
if [ -n "$XDG_DATA_HOME" ]; then
    export AUTOJUMP_DATA_DIR="$XDG_DATA_HOME/autojump"
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
AUTOJUMP='{ [[ "$AUTOJUMP_HOME" == "$HOME" ]] && (autojump -a "$(pwd -P)"&)>/dev/null 2>>"${AUTOJUMP_DATA_DIR}/.autojump_errors";} 2>/dev/null'

case $PROMPT_COMMAND in
    *autojump*)    ;;
    *)   export PROMPT_COMMAND="$AUTOJUMP ; ${PROMPT_COMMAND:-:}";;
esac

alias jumpstat="autojump --stat"
function j { new_path="$(autojump $@)";if [ -n "$new_path" ]; then echo -e "\\033[31m${new_path}\\033[0m"; cd "$new_path";else false; fi }
