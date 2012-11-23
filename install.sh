#!/usr/bin/env bash

function help_msg {
    echo "./install.sh [OPTION..]"
    echo
    echo " -a, --auto           Try to determine destdir, prefix (and zshshare if applicable)"
    echo " -g, --global         Use default global settings (destdir=/; prefix=usr)"
    echo " -l, --local          Use default local settings (destdir=~/.autojump)"
    echo
    echo " -d, --destdir PATH   Set install destination to PATH"
    echo " -p, --prefix PATH    Use PATH as prefix"
    echo " -Z, --zshshare PATH  Use PATH as zsh share destination"
    echo
    echo " -f, --force          Ignore Python version check"
    echo " -n, --dry_run        Only show installation paths, don't install anything"
    echo
    echo "Will install autojump into:"
    echo
    echo ' Binaries:        $destdir$prefix/bin'
    echo ' Documentation:   $destdir$prefix/share/man/man1'
    echo ' Icon:            $destdir$prefix/share/autojump'
    echo ' Shell scripts:   $destdir/etc/profile.d'
    echo ' zsh functions:   $destdir$zshsharedir'
    echo
    echo 'Unless specified, $zshshare will be :'
    echo ' - $destdir$prefix/functions for local installations'
    echo ' - $destdir$prefix/share/zsh/site-functions for all other installations'
}

dry_run=
local=
global=
force=
shell=`echo ${SHELL} | awk -F/ '{ print $NF }'`
destdir=
prefix="usr/local"
zshsharedir=

# If no arguments passed, default to --auto.
if [[ ${#} == 0 ]]; then
    set -- "--auto"
fi

# Only dry-run should also default to --auto
if [[ ${#} == 1 ]] && ([[ $1 = "-n" ]] || [[ $1 = "--dry-run" ]]); then
    set -- "-n" "--auto"
fi

# Command line parsing
while true; do
    case "$1" in
        -a|--auto)
            if [[ ${UID} -eq 0 ]]; then
                set -- "--global" "${@:2}"
            else
                set -- "--local" "${@:2}"
            fi
            ;;
        -d|--destdir)
            if [ $# -gt 1 ]; then
                destdir=$2; shift 2
            else
                echo "--destdir or -d requires an argument" 1>&2
            fi
            ;;
        -f|--force)
            force=true
            shift
            if [[ ${#} == 0 ]]; then
                set -- "--auto"
            fi
            ;;
        -g|--global)
            global=true
            destdir=
            prefix=usr
            shift
            ;;
        -h|--help|-\?)
            help_msg;
            exit 0
            ;;
        -l|--local)
            local=true
            destdir=~/.autojump
            prefix=
            shift
            ;;
        -n|--dry_run)
            dry_run=true
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
        -Z|--zshshare)
            if [ $# -gt 1 ]; then
                zshsharedir=$2; shift 2
            else
                echo "--zshshare or -Z requires an argument" 1>&2
                exit 1
            fi
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

# destdir must be a full path, and end with a slash
if [[ -n ${destdir} ]]; then
    if [[ ${destdir:0:1} != "/" ]]; then
        echo "Error: destdir must be a full path" 1>&2
        exit 1
    fi
    len=${#destdir}
    if [[ ${destdir:len - 1} != "/" ]]; then
        destdir="$destdir/"
    fi
else
    destdir="/"
fi

# prefix should not start with, and end with, a slash
if [[ -n ${prefix} ]]; then
    if [[ ${prefix:0:1} == "/" ]]; then
        prefix=${prefix:1}
    fi
    len=${#prefix}
    if [[ ${prefix:len - 1} != "/" ]]; then
        prefix="$prefix/"
    fi
fi

# check shell support
if [[ ${shell} != "bash" ]] && [[ ${shell} != "zsh" ]]; then
    echo "Unsupported shell (${shell}). Only Bash and Zsh shells are supported."
    exit 1
fi

# zsh functions
if [[ $shell == "zsh" ]]; then
    if [[ -z $zshsharedir ]]; then
        # if not set, use a default
        if [[ $local ]]; then
            zshsharedir="${prefix}functions"
        else
            zshsharedir="${prefix}share/zsh/site-functions"
        fi
    fi
fi

# check Python version
if [ ! ${force} ]; then
    python_version=`python -c 'import sys; print(sys.version_info[:])'`

    if [[ ${python_version:1:1} -eq 2 && ${python_version:4:1} -lt 6 ]]; then
        echo
        echo "Incompatible Python version, please upgrade to v2.6+."
        if [[ ${python_version:4:1} -ge 4 ]]; then
            echo
            echo "Alternatively, you can download v12 that supports Python v2.4+ from:"
            echo
            echo -e "\thttps://github.com/joelthelion/autojump/downloads"
            echo
        fi
        exit 1
    fi
fi

echo
echo "Installating autojump..."
echo
echo "Destination:      $destdir"
if [[ -n $prefix ]]; then
    echo "Prefix:           /$prefix"
fi
echo
echo "Binary:           ${destdir}${prefix}bin/"
echo "Documentation:    ${destdir}${prefix}share/man/man1/"
echo "Icon:             ${destdir}${prefix}share/autojump/"
echo "Shell scripts:    ${destdir}etc/profile.d/"
if [[ -z $shell ]] || [[ $shell == "zsh" ]]; then
    echo "zsh functions:    ${destdir}${zshsharedir}"
fi
echo

if [[ $dry_run ]]; then
    echo "--dry_run (-n) used, stopping"
    exit
fi

# INSTALL AUTOJUMP
mkdir -p ${destdir}${prefix}share/autojump/ || exit 1
mkdir -p ${destdir}${prefix}bin/ || exit 1
mkdir -p ${destdir}${prefix}share/man/man1/ || exit 1
cp -v ./bin/icon.png ${destdir}${prefix}share/autojump/ || exit 1
cp -v ./bin/jumpapplet ${destdir}${prefix}bin/ || exit 1
cp -v ./bin/autojump ${destdir}${prefix}bin/ || exit 1
cp -v ./bin/autojump_argparse.py ${destdir}${prefix}bin/ || exit 1
cp -v ./docs/autojump.1 ${destdir}${prefix}share/man/man1/ || exit 1
mkdir -p ${destdir}etc/profile.d/ || exit 1
cp -v ./bin/autojump.sh ${destdir}etc/profile.d/ || exit 1
cp -v ./bin/autojump.bash ${destdir}etc/profile.d/ || exit 1
cp -v ./bin/autojump.zsh ${destdir}etc/profile.d/ || exit 1
mkdir -p ${destdir}${zshsharedir} || exit 1
install -v -m 0755 ./bin/_j ${destdir}${zshsharedir} || exit 1

# MODIFY AUTOJUMP.SH FOR CUSTOM INSTALLS
if [[ -z ${local} ]] && [[ -z ${global} ]]; then
    sed -i "s:custom_install:${destdir}etc/profile.d:g" ${destdir}etc/profile.d/autojump.sh
fi

# DISPLAY ADD MESSAGE
rc_file="~/.${shell}rc"
if [[ `uname` == "Darwin" ]] && [[ ${shell} == "bash" ]]; then
    rc_file="~/.bash_profile"
fi

aj_shell_file="${destdir}etc/profile.d/autojump.sh"
if [[ ${local} ]]; then
    aj_shell_file="~/.autojump/etc/profile.d/autojump.sh"
fi

echo
echo "Please add the line to ${rc_file} :"
echo
echo -e "[[ -s ${aj_shell_file} ]] && . ${aj_shell_file}"
echo
echo "You need to run 'source ${rc_file}' before you can start using autojump. To remove autojump, run './uninstall.sh'"
echo
