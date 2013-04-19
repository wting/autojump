# source autojump on BASH or ZSH depending on the shell

shell=`echo ${SHELL} | awk -F/ '{ print $NF }'`

# prevent circular loop for sh shells
if [ "${shell}" = "sh" ]; then
	return 0

# check local install
elif [ -s ~/.autojump/etc/profile.d/autojump.${shell} ]; then
	source ~/.autojump/etc/profile.d/autojump.${shell}

# check global install
elif [ -s /etc/profile.d/autojump.${shell} ]; then
	source /etc/profile.d/autojump.${shell}

# check custom install locations (modified by Homebrew or using --destdir option)
elif [ -s custom_install/autojump.${shell} ]; then
	source custom_install/autojump.${shell}

fi
