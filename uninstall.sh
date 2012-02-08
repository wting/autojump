#!/usr/bin/env bash
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

function help_msg {
    echo "sudo ./uninstall.sh [--prefix /usr/local]"
}

function remove_j {
    # zsh: remove _j from fpath, only works within zsh
    # autocompletion file in the first directory of the FPATH variable
    #fail=true
    #for f in $fpath
    #do
        #if [ -f ${f}/_j ]; then
            #rm -v ${f}/_j || sudo rm -v ${f}/_j
            #break
        #fi
    #done
    sudo rm -v /usr/local/share/zsh/site-functions/_j
}

function remove_msg {
    if [ "${2}" == "bash" ]; then
        echo
        echo "Please remove the line from ${bashrc_file} :"
        echo
        if [ "${1}" == "global" ]; then
            echo -e "\tsource /etc/profile.d/autojump.bash"
        elif [ "${1}" == "local" ]; then
            echo -e "\tsource ~/etc/profile.d/autojump.bash"
        fi
        echo
    elif [ "${2}" == "zsh" ]; then
        echo
        echo "Please remove the line from ~/.zshrc :"
        echo
        if [ "${1}" == "global" ]; then
            echo -e "\tsource /etc/profile.d/autojump.zsh"
        elif [ "${1}" == "local" ]; then
            echo -e "\tsource ~/etc/profile.d/autojump.zsh"
        fi
        echo
    fi
}

# Default install directory.
prefix=/usr

user=${SUDO_USER:-${USER}}
OS=`uname`

if [ $OS == 'Darwin' ]; then
    user_home=$(dscl . -search /Users UniqueID ${user} | cut -d: -f6)
else
    user_home=$(getent passwd ${user} | cut -d: -f6)
fi
bashrc_file=${user_home}/.bashrc

# Command line parsing
while true; do
    case "$1" in
        -h|--help|-\?) help_msg; exit 0;;
        -p|--prefix)
            if [ $# -gt 1 ]; then
                prefix=$2; shift 2
            else
                echo "--prefix or -p require an argument" 1>&2
                exit 1
            fi
            ;;
        --) shift; break;;
        -*) echo "invalid option: $1" 1>&2; help_msg; exit 1;;
        *)  break;;
    esac
done

# UNINSTALL AUTOJUMP
# global / custom location installations
if [ -d "${prefix}/share/autojump/" ]; then
    echo
    echo "Uninstalling from ${prefix} ..."
    echo
    sudo rm -rv ${prefix}/share/autojump/
    sudo rm -v ${prefix}/bin/jumpapplet
    sudo rm -v ${prefix}/bin/autojump
    sudo rm -v ${prefix}/share/man/man1/autojump.1
    sudo rm -v /etc/profile.d/autojump.sh
    if [ -f /etc/profile.d/autojump.bash ]; then
        sudo rm -v /etc/profile.d/autojump.bash
        remove_msg "global" "bash"
    fi
    if [ -f /etc/profile.d/autojump.zsh ]; then
        sudo rm -v /etc/profile.d/autojump.zsh
        remove_msg "global" "zsh"
    fi
fi

# local installations
if [ -d ~/.autojump/ ]; then
    echo
    echo "Uninstalling from ~/.autojump/ ..."
    echo

    if [ -f ~/.autojump/etc/profile.d/autojump.bash ]; then
        rm -rv ~/.autojump/
        remove_msg "local" "bash"
    fi
    if [ -f ~/.autojump/etc/profile.d/autojump.zsh ]; then
        rm -rv ~/.autojump/
        remove_msg "local" "zsh"
    fi
fi
