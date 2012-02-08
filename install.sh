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

function show_help {
    echo "sudo ./install.sh [--local] [--prefix /usr/local]"
}

# Default install directory.
prefix=/usr
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
            show_help;
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
                die "--prefix or -p require an argument"
            fi
            ;;
        --)
            shift
            break
            ;;
        -*)
            echo "invalid option: $1" 1>&2;
            show_help;
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

if [ ! ${local} ]; then
    if [ -d "/etc/profile.d" ]; then
        cp -v autojump.bash /etc/profile.d/
        cp -v autojump.sh /etc/profile.d/

        echo
        echo "Add the following lines to your ~/.bashrc:"
        echo
        echo -e "\tsource ${prefix}/etc/profile.d/autojump.bash"
        echo
        echo "You need to source your ~/.bashrc (source ~/.bashrc) before you can start using autojump."
        echo
        echo "To remove autojump, delete the ${prefix} directory and relevant lines from ~/.bashrc."
        echo
    else
        echo "Your distribution does not have a '/etc/profile.d/' directory, please create it manually or use the local install option."
    fi
else
    mkdir -p ${prefix}/etc/profile.d/
    cp -v autojump.bash ${prefix}/etc/profile.d/
    cp -v autojump.sh ${prefix}/etc/profile.d/

    echo
    echo "Add the following lines to your ~/.bashrc:"
    echo
    echo -e "\tsource ${prefix}/etc/profile.d/autojump.bash"
    echo
    echo "You need to source your ~/.bashrc (source ~/.bashrc) before you can start using autojump."
    echo
    echo "To remove autojump, delete the ${prefix} directory and relevant lines from ~/.bashrc."
    echo
fi
