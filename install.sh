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
local=0

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
            local=1
            prefix=~/.autojump
            shift
            ;;
        -p|--prefix)
            if [ $# -gt 1 ]; then
                prefix=$2; shift 2
                profile_d=$prefix/etc/autojump
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

echo "Installing main files to ${prefix} ..."

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

        # Make sure that the code we just copied has been sourced.
        # check if .bashrc has sourced /etc/profile or /etc/profile.d/autojump.bash
        if [ `grep -c "^[[:space:]]*\(source\|\.\) /etc/profile\(\.d/autojump\.bash\)[[:space:]]*$" ${bashrc_file}` -eq 0 ]; then
            echo "Your .bashrc doesn't seem to source /etc/profile or $profile_d/autojump.bash"
            echo "Adding the /etc/profile.d/autojump.bash to your .bashrc"
            echo "" >> ${bashrc_file}
            echo "# Added by autojump install.sh" >> ${bashrc_file}
            echo "source /etc/profile.d/autojump.bash" >> ${bashrc_file}
        fi
        echo "Done!"
        echo
        echo "You need to source your ~/.bashrc (source ~/.bashrc) before you can start using autojump."
    else
        echo "Your distribution does not have a $profile_d directory, the default that we install one of the scripts to. Would you like us to copy it into your ~/.bashrc file to make it work? (If you have done this once before, delete the old version before doing it again.) [y/n]"
        read ans
        if [ ${#ans} -gt 0 ]; then
            if [ $ans = "y" -o $ans = "Y" -o $ans = "yes" -o $ans = "Yes" ]; then
                # Answered yes. Go ahead and add the autojump code
                echo "" >> ${bashrc_file}
                echo "#autojump" >> ${bashrc_file}
                cat autojump.bash | grep -v "^#" >> ${bashrc_file}

                    # Since OSX uses .bash_profile, we need to make sure that .bashrc is properly sourced.
                    # Makes the assumption that if they have a line: source ~/.bashrc or . ~/.bashrc, that
                    # .bashrc has been properly sourced and you don't need to add it.
                    if [ $OS == 'Darwin' -a x`grep -c "^[[:space:]]*\(source\|\.\) ~/\.bashrc[[:space:]]*$" ~/.bash_profile` == x0 ]; then
                        echo "You are using OSX and your .bash_profile doesn't seem to be sourcing .bashrc"
                        echo "Adding source ~/.bashrc to your bashrc"
                        echo -e "\n# Get the aliases and functions" >> ~/.bash_profile
                        echo -e "if [ -f ${bashrc_file} ]; then\n  . ${bashrc_file}\nfi" >> ~/.bash_profile
                    fi
                    echo "You need to source your ~/.bashrc (source ~/.bashrc) before you can start using autojump."
            else
                echo "Then you need to put autojump.sh, or the code from it, somewhere where it will get read. Good luck!"
            fi
        else
            echo "Then you need to put autojump.sh, or the code from it, somewhere where it will get read. Good luck!"
        fi
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
fi

