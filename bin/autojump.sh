# source autojump on BASH or ZSH depending on the shell

shell=`echo ${SHELL} | awk -F/ '{ print $NF }'`

# check local install
if [ -s ~/.autojump/etc/profile.d/autojump.${shell} ]; then
	source ~/.autojump/etc/profile.d/autojump.${shell}

# check global install
elif [ -s /etc/profile.d/autojump.${shell} ]; then
	source /etc/profile.d/autojump.${shell}

fi
