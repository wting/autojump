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
        echo "sudo ./install.sh [--prefix /usr/local]"
}

# Command line parsing
while true; do
    case "$1" in
      -h|--help|-\?) show_help; exit 0;;
      -p|--prefix) if [ $# -gt 1 ]; then
            prefix=$2; shift 2
          else 
            echo "--prefix or -p require an argument" 1>&2
            exit 1
          fi ;;
      --) shift; break;;
      -*) echo "invalid option: $1" 1>&2; show_help; exit 1;;
      *)  break;;
    esac
done

uninstall=0;
if [ -f "/usr/bin/autojump" ]; then
    while true; do
        read -p "Old installation detected, remove? [Yn] " yn
        case $yn in
            [Yy]* ) uninstall=1; break;;
            [Nn]* ) "Already installed, exiting." exit 1;;
            * ) uninstall=1; break;;
        esac
    done
fi

if [ ${uninstall} == 1 ]; then
    echo "Deleting old installation files ..."
    sudo rm -r /usr/share/autojump/
    sudo rm /usr/bin/autojump
    sudo rm /usr/bin/jumpapplet
    sudo rm /usr/share/man/man1/autojump.1
fi

all_users=0;
while true; do
    read -p "Install for all users (requires root)? [Yn] " yn
    case $yn in
        [Yy]* ) all_users=1; break;;
        [Nn]* ) all_users=0; break;;
        * ) all_users=1; break;;
    esac
done

prefix=/usr/local
if [ ${all_users} == 0 ]; then
    prefix=${HOME}/.autojump
fi

echo "Installing to ${prefix} ..."

# INSTALL AUTOJUMP
if [ ${all_users} == 1 ]; then
    sudo mkdir -p ${prefix}/share/autojump/
    sudo mkdir -p ${prefix}/bin/
    sudo mkdir -p ${prefix}/share/man/man1/
    sudo cp icon.png ${prefix}/share/autojump/
    sudo cp jumpapplet ${prefix}/bin/
    sudo cp autojump ${prefix}/bin/
    sudo cp autojump.1 ${prefix}/share/man/man1/
    sudo mkdir -p /etc/profile.d/
    sudo cp autojump.bash /etc/profile.d/
    sudo cp autojump.sh /etc/profile.d/

    # Fail sudo install
    if [ ! -f ${prefix}/bin/autojump ] || [ ! -f ${prefix}/share/man/man1/autojump.1 ] || [ ! -f /etc/profile.d/autojump.bash ] || [ ! -f /etc/profile.d/autojump.sh ]; then
        echo "Autojump was not installed, please try again using single user installation or with the correct sudo password."
        exit 1
    fi

    # Make sure that the code we just copied has been sourced.
    # check if .bashrc has sourced /etc/profile or /etc/profile.d/autojump.bash
    if [ `grep -c "^[[:space:]]*\(source\|\.\) /etc/profile\(\.d/autojump\.bash\)[[:space:]]*$" ~/.bashrc` -eq 0 ]; then
        echo "Your .bashrc doesn't seem to source /etc/profile or /etc/profile.d/autojump.bash"
        echo "Adding the /etc/profile.d/autojump.bash to your .bashrc"
        echo "" >> ~/.bashrc
        echo "# Added by autojump install.sh" >> ~/.bashrc
        echo "source /etc/profile.d/autojump.bash" >> ~/.bashrc
    fi
else
    mkdir -p ${prefix}/share/autojump/
    mkdir -p ${prefix}/bin/
    mkdir -p ${prefix}/share/man/man1/
    cp icon.png ${prefix}/share/autojump/
    cp jumpapplet ${prefix}/bin/
    cp autojump ${prefix}/bin/
    cp autojump.1 ${prefix}/share/man/man1/
    mkdir -p ${prefix}/etc/profile.d/
    cp autojump.bash ${prefix}/etc/profile.d/
    cp autojump.sh ${prefix}/etc/profile.d/

    if [ `grep -c "^[[:space:]]*\(source\|\.\) ${prefix}/etc/profile\(\.d/autojump\.bash\)[[:space:]]*$" ~/.bashrc` -eq 0 ]; then
        echo "Your .bashrc doesn't seem to source /etc/profile or /etc/profile.d/autojump.bash"
        echo "Adding the /etc/profile.d/autojump.bash to your .bashrc"
        echo "" >> ~/.bashrc
        echo "# Added by autojump install.sh" >> ~/.bashrc
        echo "source ${prefix}/etc/profile.d/autojump.bash" >> ~/.bashrc
    fi

    if [ `grep -c ".*PATH.*.autojump/bin" ~/.bashrc` -eq 0 ]; then
        echo "Your .bashrc doesn't seem to have ${prefix}/bin in your \$PATH"
        echo "Adding the ${prefix}/bin/ to your PATH"
        echo "" >> ~/.bashrc
        echo "# Added by autojump install.sh" >> ~/.bashrc
        echo 'export PATH=${PATH}:~/.autojump/bin' >> ~/.bashrc
    fi

fi

# Since OSX uses .bash_profile, we need to make sure that .bashrc is properly sourced.
# Makes the assumption that if they have a line: source ~/.bashrc or . ~/.bashrc, that
# .bashrc has been properly sourced and you don't need to add it.
if [ `uname` == "Darwin" ] && [ `grep -c "^[[:space:]]*\(source\|\.\).*\.bashrc[[:space:]]*$" ~/.bash_profile` -eq 0 ]; then
    echo "Your .bash_profile doesn't seem to be sourcing .bashrc"
    echo "Adding source ~/.bashrc to your bashrc"
    echo -e "\n# Get the aliases and functions" >> ~/.bash_profile
    echo -e "if [ -f ~/.bashrc ]; then\n  . ~/.bashrc\nfi" >> ~/.bash_profile
fi

echo "Done!"
echo
echo "You need to source your ~/.bashrc (source ~/.bashrc) before you can start using autojump."
