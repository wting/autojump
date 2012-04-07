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

# determine the data directory according to the XDG Base Directory Specification
if [[ -n ${XDG_DATA_HOME} ]] && [[ ${XDG_DATA_HOME} =~ ${USER} ]]; then
    export AUTOJUMP_DATA_DIR="${XDG_DATA_HOME}/autojump"
else
    export AUTOJUMP_DATA_DIR=${HOME}/.local/share/autojump
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

alias jumpstat="autojump --stat"

function j {
    local new_path="$(autojump $@)"

    if [ -d "${new_path}" ]; then
        echo -e "\\033[31m${new_path}\\033[0m"
        cd "${new_path}"
    else
        echo "autojump returns: ${new_path}"
        echo "autojump: directory '${@}' not found"
        echo "Try \`autojump --help\` for more information."
        false
    fi
}
