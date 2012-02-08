#!/usr/bin/env zsh
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
	echo "sudo ./uninstall.zsh [--prefix /usr/local]"
}

# Default install directory.
prefix=/usr

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


# UNINSTALL AUTOJUMP
# global / custom location installations
if [[ -d "${prefix}/share/autojump/" ]]; then
	echo -e "\nUninstalling from ${prefix} ...\n"
	sudo rm -rv ${prefix}/share/autojump/
	sudo rm -v ${prefix}/bin/jumpapplet
	sudo rm -v ${prefix}/bin/autojump
	sudo rm -v ${prefix}/share/man/man1/autojump.1
	sudo rm -v /etc/profile.d/autojump.zsh
	sudo rm -v /etc/profile.d/autojump.sh
fi

# local installations
if [[ -d ~/.autojump/ ]]; then
	echo -e "\nUninstalling from ~/.autojump/ ...\n"
	rm -rv ~/.autojump/
fi

# autocompletion file in the first directory of the FPATH variable
fail=true
for f in $fpath
do
	if [[ -f ${f}/_j ]]; then
		sudo rm -v ${f}/_j
		break
	fi
done

echo -e "\nPlease remove the line from ~/.zshrc :\n"
echo -e "\tsource /etc/profile.d/autojump.zsh"
