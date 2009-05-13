# Source autojump on BASH or ZSH depending on the shell
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
if [ "$BASH_VERSION" ] && [ -n "$PS1" ] && echo $SHELLOPTS | grep -v posix >>/dev/null; then
	. /etc/profile.d/autojump.bash
elif [ "$ZSH_VERSION" ] && [ -n "$PS1" ]; then
    . /etc/profile.d/autojump.zsh
fi
