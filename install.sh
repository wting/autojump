sudo mkdir -p /usr/share/autojump/
sudo cp icon.png /usr/share/autojump/
sudo cp jumpapplet /usr/bin/
sudo cp autojump /usr/bin/
sudo cp autojump.1 /usr/share/man/man1/
if [ -d "/etc/profile.d" ]; then
    sudo cp autojump.bash /etc/profile.d/
    sudo cp autojump.sh /etc/profile.d/
    echo "Remember to add the line" 
    echo "    source /etc/profile.d/autojump.bash"
    echo "or"
    echo "    source /etc/profile"
    echo "to your ~/.bashrc if it's not there already"
    # TODO intelligently source /etc/profile for them if the line isn't already in their .bashrc
else
    echo "Your distribution does not have a /etc/profile.d directory, the default that we install one of the scripts to. Would you like us to copy it into your ~/.bashrc file to make it work? (If you have done this once before, delete the old version before doing it again.) [y/n]"
    read ans
    if [ ${#ans} -gt 0 ]; then
	if [ $ans = "y" -o $ans = "Y" -o $ans = "yes" -o $ans = "Yes" ]; then
	    echo "" >> ~/.bashrc
	    echo "#autojump" >> ~/.bashrc
	    cat autojump.bash >> ~/.bashrc
	else
	    echo "Then you need to put autojump.sh, or the code from it, somewhere where it will get read. Good luck!"
	fi
    else
    	    echo "Then you need to put autojump.sh, or the code from it, somewhere where it will get read. Good luck!"
    fi
fi
