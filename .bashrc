# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# User specific aliases and functions
#PS1=\\h:\\u:\\w\\$
PS1=\\h:\\w\\$

#stty erase '^h'
tty -s && stty erase '^?'
tty -s && stty stop undef
#echo -e -n "\033k""`hostname`""\033\\"

#
# function
#

findf(){
find . \( -type f -o -type l \) -print | xargs grep -i "$1"
}

root(){
##su root -c 'exec bash --login'
##LC_ALL=C su root -c "HOME=/home/$USER exec bash --login"
##LC_ALL=C su --preserve-environment
##su --preserve-environment
LC_ALL=C su - root -c "HOME=/home/$USER bash --login -i"
}

mkinitrd_armadillo(){
  mkinitrd -v -f --without-dmraid /boot/initrd-`uname -r`.img `uname -r`
}

#
# alias
#

alias wakeupsei='wakeonlan 00:0E:A6:A5:8A:71'
alias t=tm
alias sc='screen'
alias scx='screen -x'
#alias scx='screen -U -D -RR'
alias scw='screen -wipe'
alias scls='screen -ls'
#alias m=lv
alias m=less
alias v=vim
alias vi=vim
#alias less=jless
alias c=cat
alias l='ls -al'
alias ll='ls -al | lv'
alias d='ls -lFo'
#alias t=tail
alias p='ps -aef'
alias mq='mailq'
alias nsna='netstat -na'
alias nsnr='netstat -nr'
alias ..='cd ..'
alias ...='cd ../..'
alias -- -='cd -'

##eval `lazy-ssh-agent setup ssh scp sftp`

