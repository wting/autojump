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
        echo -e "\tsource ~/.autojump/etc/profile.d/autojump.${2}"
    fi

    echo
    echo "You need to run 'source ~/.${2}rc' before you can start using autojump."
    echo
    echo "To remove autojump, run './uninstall.sh'"
    echo
}

function help_msg {
    echo
    echo "./install.sh [--global or --local] [--bash or --zsh] [--prefix /usr/] "
    echo
    echo "If run without any arguments, the installer will:"
    echo
    echo -e "\t- as root install globally into /usr/"
    echo -e "\t- as non-root install locally to ~/.autojump/"
    echo -e "\t- version will be based on \$SHELL environmental variable"
    echo
}

# Default install directory.
shell=`echo ${SHELL} | awk -F/ '{ print $NF }'`
if [[ ${UID} -eq 0 ]]; then
    local=
    prefix=/usr
else
    local=true
    prefix=~/.autojump
fi

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
        -b|--bash)
            shell="bash"
            shift
            ;;
        -g|--global)
            local=
            shift
            ;;
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
                echo "--prefix or -p requires an argument" 1>&2
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

# check for valid local install options
if [[ ${UID} != 0 ]] && [ ! ${local} ]; then
    echo
    echo "Please rerun as root or use the --local option."
    echo
    exit 1
fi

# check shell if supported
if [[ ${shell} != "bash" ]] && [[ ${shell} != "zsh" ]]; then
    echo "Unsupported shell (${shell}). Use --bash or --zsh to explicitly define shell."
    exit 1
fi

# check Python version
python_version=`python -c 'import sys; print(sys.version_info[:])'`
if [[ ${python_version:1:1} -eq 2 && ${python_version:4:1} -lt 6 ]]; then
    echo
    echo "Incompatible Python version, please upgrade to v2.6+ or v3.0+."
    if [[ ${python_version:4:1} -gt 3 ]]; then
        echo
        echo "Alternatively, you can download v12 that supports Python v2.4+ from:"
        echo
        echo -e "\thttps://github.com/joelthelion/autojump/tags"
        echo
    fi
    exit 1
fi

echo
echo "Installing ${shell} version of autojump to ${prefix} ..."
echo

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
        fpath=`/usr/bin/env zsh -c 'echo $fpath'`
        for f in ${fpath}; do
            cp -v _j ${f} && success=true && break
        done

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
