# Djosix 2017.05.30


# bin
PATH=~/.dots/bin:$PATH
test -d ~/.bin && PATH=~/.bin:$PATH


# locales
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LC_CTYPE=UTF-8


# aliases
alias ls="ls -G"
alias d="rm -rf"
alias l="ls -F"
alias la="ls -alh"
alias ll="ls -lh"
alias e="exit"
alias m="make"
alias v="vim"
alias s="sudo"
alias cho="sudo chown"
alias chm="sudo chmod"
alias tm="tmux"
alias tma="tmux attach"
alias tmat="tmux attach -t"
alias jn="jupyter-notebook"
alias py="python"
alias ipy="ipython"
alias ipdb="ipython --pdb --"
alias cs="cd ~/Space"
alias cds="cd ~/Dropbox/Space"
alias cdd="cd ~/Desktop"
alias cdl="cd ~/Downloads"
alias cdt="cd ~/Tools"
alias cdc="cd ~/Documents"
alias cdb="cd ~/Dropbox/"
alias tmp="mkdir -p /tmp/$USER; cd /tmp/$USER"
alias youtube-dl-smart="youtube-dl --ignore-errors --download-archive .youtube-dl"
alias youtube-mp3="youtube-dl -x --audio-format mp3"
alias youtube-mp3-smart="youtube-mp3 --ignore-errors --download-archive .youtube-dl"
alias du="du -h"
alias df="df -h"
alias dr='docker run -it -v $PWD:/root/workdir -w /root/workdir'
alias drs='dr --cap-add=SYS_PTRACE --security-opt seccomp=unconfined'

findname() {
    find . -name "*$1*"
}

mcd() {
    mkdir -p $@
    cd $@
}


# lazy git
alias gaa="git add -A"
alias gst="git status"
alias glg="git log"
alias ggi="git init"
alias gra="git remote add"
alias gcm="git commit -m"
alias gct='git commit -m "$(date +"Update %Y/%m/%d %H:%M:%S")"'
alias gcl="git clone"
alias gck="git checkout"
alias gbh="git branch"
alias gpsh="git push"
alias gpom="git push origin master"
alias gplom="git pull origin master"
alias grst="git reset"

[ "$USER" = root ] || SUDO=sudo

# native aliases
if [ `uname` = Linux ]; then
    alias i="$SUDO apt install -y"
    alias u="$SUDO apt update && sudo apt upgrade -y"
    alias sctl="$SUDO systemctl"
    alias ssv="$SUDO service"
    alias sv="$SUDO service"
    alias ctl="$SUDO systemctl"
    alias ram="mkdir -p /dev/shm/$USER; cd /dev/shm/$USER"
    alias ls="ls --color=always"
elif [ `uname` = Darwin ]; then
    alias dds="find . -name .DS_Store -exec rm -v {} +"
    alias i="brew install"
fi

