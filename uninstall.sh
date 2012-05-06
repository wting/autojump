#!/usr/bin/env bash

function help_msg {
    echo "sudo ./uninstall.sh [--prefix /usr/local]"
}

function remove_msg {
    echo
    echo "Please remove the line from .${2}rc :"
    echo
    if [ "${1}" == "global" ]; then
        echo -e "\t[[ -s /etc/profile.d/autojump.${2} ]] && source /etc/profile.d/autojump.${2}"
    elif [ "${1}" == "local" ]; then
        echo -e "\t[[ -s ~/.autojump/etc/profile.d/autojump.${2} ]] && source ~/.autojump/etc/profile.d/autojump.${2}"
    fi
    echo
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

        fpath=`/usr/bin/env zsh -c 'echo $fpath'`
        for f in ${fpath}; do
            if [[ -f ${f}/_j ]]; then
                sudo rm -v ${f}/_j
            fi
        done

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
