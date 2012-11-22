#!/usr/bin/env bash

function help_msg {
    echo "./install.sh [OPTION..]"
    echo
    echo " -a, --auto           Try to determine destdir, prefix, shell (and zshshare if apply)"
    echo " -g, --global         Use default global settings (destdir=/; prefix=usr)"
    echo " -l, --local          Use default local settings (destdir=~/.autojump)"
    echo
    echo " -d, --destdir PATH   Set install destination to PATH"
    echo " -p, --prefix PATH    Use PATH as prefix"
    echo " -Z, --zshshare PATH  Use PATH as zsh share destination"
    echo
    echo " -b, --bash           Install for bash only"
    echo " -z, --zsh            Install for zsh only"
    echo " (If neither are specified, both bash & zsh support are installed)"
    echo
    echo " -f, --force          Ignore python version check"
    echo " -P, --show_path      Only show installation paths, don't install anything"
    echo
    echo "Will install autojump into:"
    echo ' Binaries:        $destdir$prefix/bin'
    echo ' Documentation:   $destdir$prefix/share/man/man1'
    echo ' Icon:            $destdir$prefix/share/autojump'
    echo ' Shell scripts:   $destdir/etc/profile.d'
    echo ' zsh functions:   $destdir$zshsharedir'
    echo
    echo 'Unless specified, $zshshare will be :'
    echo ' - First writable directory in $fpath when --auto was used'
    echo ' - $destdir$prefix/functions if --local was used'
    echo ' - $destdir$prefix/share/zsh/site-functions'
}

show_path=
auto=
local=
force=
shell=
destdir=
prefix="usr/local"
zshsharedir=

# If no arguments passed, default to --auto.
if [[ ${#} == 0 ]]; then
    set -- "--auto"
fi

# Command line parsing
while true; do
    case "$1" in
        -a|--auto)
            zshsharedir=
            if [[ ${UID} -eq 0 ]]; then
                set -- "--global" "${@:2}"
            else
                set -- "--local" "${@:2}"
            fi
            ;;
        -b|--bash)
            shell="bash"
            shift
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
            ;;
        -g|--global)
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
        -P|--show_paths)
            show_path=true
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

# check shell if supported
if [[ -n ${shell} ]] && [[ ${shell} != "bash" ]] && [[ ${shell} != "zsh" ]]; then
    echo "Unsupported shell (${shell}). Use --bash or --zsh to explicitly define shell."
    exit 1
fi

# zsh functions
if [[ -z $shell ]] || [[ $shell == "zsh" ]]; then
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
if [[ -n $shell ]]; then
    echo "Shell:            $shell"
else
    echo "Shell:            bash & zsh"
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

if [[ $show_path ]]; then
    echo "--show_path (-P) used, stopping"
    exit
fi

# INSTALL AUTOJUMP
mkdir -p ${destdir}${prefix}share/autojump/
mkdir -p ${destdir}${prefix}bin/
mkdir -p ${destdir}${prefix}share/man/man1/
cp -v ./bin/icon.png ${destdir}${prefix}share/autojump/
cp -v ./bin/jumpapplet ${destdir}${prefix}bin/
cp -v ./bin/autojump ${destdir}${prefix}bin/
cp -v ./bin/autojump_argparse.py ${destdir}${prefix}bin/
cp -v ./docs/autojump.1 ${destdir}${prefix}share/man/man1/
mkdir -p ${destdir}etc/profile.d/
cp -v ./bin/autojump.sh ${destdir}etc/profile.d/
if [[ -z $shell ]] || [[ $shell == "bash" ]]; then
    cp -v ./bin/autojump.bash ${destdir}etc/profile.d/
fi
if [[ -z $shell ]] || [[ $shell == "zsh" ]]; then
    cp -v ./bin/autojump.zsh ${destdir}etc/profile.d/
    mkdir -p ${destdir}${zshsharedir}
    install -v -m 0755 ./bin/_j ${destdir}${zshsharedir}
fi

echo "Remember: you need to source ${destdir}etc/profile.d/autojump.sh before you can use autojump"

