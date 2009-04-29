#! /bin/zsh
# applet icon
sudo mkdir -p /usr/share/autojump/
sudo cp icon.png /usr/share/autojump/

# scripts
sudo cp jumpapplet /usr/bin/
sudo cp autojump /usr/bin/

# man pages
sudo cp autojump.1 /usr/share/man/man1/

# autocompletion file in the first directory of the FPATH variable
sudo cp _j $(echo $FPATH | cut -d":" -f 1)


if [ -d "/etc/profile.d" ]; then
    sudo cp autojump.zsh /etc/profile.d/
    sudo cp autojump.sh /etc/profile.d/
    echo "Remember to add the line" 
    echo "    source /etc/profile.d/autojump.zsh"
    echo "or"
    echo "    source /etc/profile"
    echo "to your ~/.zshrc if it's not there already"
else
    echo "Your distribution does not have a /etc/profile.d directory, the default that we install one of the scripts to. Would you like us to copy it into your ~/.zshrc file to make it work? (If you have done this once before, delete the old version before doing it again.) [y/n]"
    read ans
    if [ ${#ans} -gt 0 ]; then
	if [ $ans = "y" -o $ans = "Y" -o $ans = "yes" -o $ans = "Yes" ]; then
	    echo "" >> ~/.zshrc
	    echo "#autojump" >> ~/.zshrc
	    cat autojump.zsh >> ~/.zshrc
	else
	    echo "Then you need to put autojump.zsh, or the code from it, somewhere where it will get read. Good luck!"
	fi
    else
    	    echo "Then you need to put autojump.zsh, or the code from it, somewhere where it will get read. Good luck!"
    fi
fi
