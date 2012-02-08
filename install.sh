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

function add_msg {
    echo
    echo "Please add the line to ~/.${2}rc :"
    echo

    if [ "${1}" == "global" ]; then
        echo -e "\tsource /etc/profile.d/autojump.${2}"
    elif [ "${1}" == "local" ]; then
        echo -e "\tsource ~/etc/profile.d/autojump.${2}"
    fi

    echo
    echo "You need to run 'source ~/.${2}rc' before you can start using autojump."
    echo
    echo "To remove autojump, run './uninstall.sh'"
    echo
}

function help_msg {
    echo "sudo ./install.sh [--local] [--prefix /usr/local]"
}

# Default install directory.
prefix=/usr
shell="bash"
local=

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
        -h|--help|-\?)
            help_msg;
            exit 0
            ;;
        -l|--local)
            local=true
            prefix=~/.autojump
            shift
            ;;
        -p|--prefix)
            if [ $# -gt 1 ]; then
                prefix=$2; shift 2
            else
                echo "--prefix or -p require an argument" 1>&2
                exit 1
            fi
            ;;
        -z|--zsh)
            shell="zsh"
            shift
            ;;
        --)
            shift
            break
            ;;
        -*)
            echo "invalid option: $1" 1>&2;
            help_msg;
            exit 1
            ;;
        *)
            break
            ;;
    esac
done

if [[ ${UID} != 0 ]] && [ ! ${local} ]; then
    echo "Please rerun as root or use the --local option."
    exit 1
fi

echo -e "Installing files to ${prefix} ...\n"

# add git revision to autojump
./git-version.sh

# INSTALL AUTOJUMP
mkdir -p ${prefix}/share/autojump/
mkdir -p ${prefix}/bin/
mkdir -p ${prefix}/share/man/man1/
cp -v icon.png ${prefix}/share/autojump/
cp -v jumpapplet ${prefix}/bin/
cp -v autojump ${prefix}/bin/
cp -v autojump.1 ${prefix}/share/man/man1/

# global installation
if [ ! ${local} ]; then
    # install _j to the first accessible directory
    if [ ${shell} == "zsh" ]; then
        success=
        cp -v _j /usr/local/share/zsh/site-functions/ $f && success=true

        if [ ! ${success} ]; then
            echo
            echo "Couldn't find a place to put the autocompletion file, please copy _j into your \$fpath"
            echo "Installing the rest of autojump ..."
            echo
        fi
    fi

    if [ -d "/etc/profile.d" ]; then
        cp -v autojump.sh /etc/profile.d/
        cp -v autojump.${shell} /etc/profile.d/
        add_msg "global" ${shell}
    else
        echo "Your distribution does not have a '/etc/profile.d/' directory, please create it manually or use the local install option."
    fi
else # local installation
    mkdir -p ${prefix}/etc/profile.d/
    cp -v autojump.sh ${prefix}/etc/profile.d/
    cp -v autojump.${shell} ${prefix}/etc/profile.d/

    if [ ${shell} == "zsh" ]; then
        mkdir -p ${prefix}/functions/
        cp _j ${prefix}/functions/
    fi

    add_msg "local" ${shell}
fi
