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
	echo "sudo ./install.zsh [--local] [--prefix /usr/local]"
}

prefix=/usr
local=false

#command line parsing
while true; do
	case "$1" in
		-h|--help|-\?)
			show_help
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
		--)
			shift
			break
			;;
		-*)
			echo "invalid option: $1" 1>&2
			show_help
			exit 1
			;;
		*)
			break
			;;
	esac
done

if [[ ${UID} != 0 ]] && ! ${local}; then
	echo "Please rerun as root or use the --local option."
	exit 1
fi

echo "Installing main files to ${prefix} ..."

# add git revision to autojump
./git-version.sh

mkdir -p ${prefix}/share/autojump/
mkdir -p ${prefix}/bin/
mkdir -p ${prefix}/share/man/man1/
cp icon.png ${prefix}/share/autojump/
cp jumpapplet ${prefix}/bin/
cp autojump ${prefix}/bin/
cp autojump.1 ${prefix}/share/man/man1/

# autocompletion file in the first directory of the FPATH variable
if ( ! ${local} ); then
	fail=true
	for f in $fpath
	do
		cp _j $f && fail=false && break
	done
	if $fail
	then
		echo "Couldn't find a place to put the autocompletion file, please copy _j into your \$fpath"
		echo "Still trying to install the rest of autojump..."
	else
		echo "Installed autocompletion file to $f"
	fi

	if [ -d "/etc/profile.d" ]; then
		cp -v autojump.zsh /etc/profile.d/
		cp -v autojump.sh /etc/profile.d/
		echo
		echo "Add the following line to your ~/.zshrc:"
		echo
		echo -e "\tsource /etc/profile.d/autojump.zsh"
		echo
		echo "You need to source your ~/.zshrc (source ~/.zshrc) before you can start using autojump."
	else
		echo "Your distribution does not have a /etc/profile.d directory, the default that we install one of the scripts to. Would you like us to copy it into your ~/.zshrc file to make it work? (If you have done this once before, delete the old version before doing it again.) [y/n]"
		read ans
		if [ ${#ans} -gt 0 ]; then
			if [ $ans = "y" -o $ans = "Y" -o $ans = "yes" -o $ans = "Yes" ]; then
				echo "" >> ~/.zshrc
				echo "#autojump" >> ~/.zshrc
				cat autojump.zsh >> ~/.zshrc
					echo "Done!"
					echo
					echo "You need to source your ~/.zshrc (source ~/.zshrc) before you can start using autojump."
			else
				echo "Then you need to put autojump.zsh, or the code from it, somewhere where it will get read. Good luck!"
			fi
		else
			echo "Then you need to put autojump.zsh, or the code from it, somewhere where it will get read. Good luck!"
		fi
	fi
else
	mkdir -p ${prefix}/functions/
	cp _j ${prefix}/functions/

	mkdir -p ${prefix}/etc/profile.d/
	cp autojump.zsh ${prefix}/etc/profile.d/
	cp autojump.sh ${prefix}/etc/profile.d/

	echo
	echo "Add the following lines to your ~/.zshrc:"
	echo
	echo -e "\tsource ${prefix}/etc/profile.d/autojump.zsh"
	echo
	echo "You need to source your ~/.zshrc (source ~/.zshrc) before you can start using autojump."
	echo
	echo "To remove autojump, delete the ${prefix} directory and relevant lines from ~/.zshrc."
fi
