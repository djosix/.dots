if [ `uname` = Linux ]; then
    source ~/.dots/bash/ubuntu.sh
else
    PS1="\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ "
fi

source ~/.dots/zsh/config.zsh
source ~/.dots/zsh/ls_colors.zsh
[ -f ~/.bashlocal ] && source ~/.bashlocal
