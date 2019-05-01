#!/bin/bash

#
# Colors for ls
#
export LS_COLORS='rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=00:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arc=01;31:*.arj=01;31:*.taz=01;31:*.lha=01;31:*.lz4=01;31:*.lzh=01;31:*.lzma=01;31:*.tlz=01;31:*.txz=01;31:*.tzo=01;31:*.t7z=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.dz=01;31:*.gz=01;31:*.lrz=01;31:*.lz=01;31:*.lzo=01;31:*.xz=01;31:*.zst=01;31:*.tzst=01;31:*.bz2=01;31:*.bz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.war=01;31:*.ear=01;31:*.sar=01;31:*.rar=01;31:*.alz=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.cab=01;31:*.wim=01;31:*.swm=01;31:*.dwm=01;31:*.esd=01;31:*.jpg=01;35:*.jpeg=01;35:*.mjpg=01;35:*.mjpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.webm=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.m4a=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.oga=00;36:*.opus=00;36:*.spx=00;36:*.xspf=00;36:';
export LSCOLORS=Exfxcxdxbxegedabagacad

#
# PATH settings
#
PATH="$HOME/.dots/bin:$PATH"
test -d $HOME/.bin && PATH="$HOME/.bin:$PATH"
export PATH


#
# Locale settings
#
export LC_CTYPE=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8


#
# Aliases and shortcuts
#
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
alias dr='docker run -it --rm -v $PWD:/root/workdir -w /root/workdir'
alias drs='dr --cap-add=SYS_PTRACE --security-opt seccomp=unconfined'

findname() {
    find . -name "*$1*"
}

mcd() {
    mkdir -p $@
    cd $@
}


#
# Git shortcuts
#
alias gaa="git add -A"
alias gau="git add -u"
alias gst="git status"
alias glg="git log"
alias ggi="git init"
alias gra="git remote add"
alias gcm="git commit -m"
alias gct='git commit -m "$(date +"Update %Y/%m/%d %H:%M:%S")"'
alias gcl="git clone"
alias gcl1="gcl --depth 1"
alias gck="git checkout"
alias gbh="git branch"
alias gpsh="git push"
alias gpom="git push origin master"
alias gplom="git pull origin master"
alias grst="git reset"


#
# Native aliases
#
[ "$USER" = root ] || SUDO=sudo
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


#
# Others
#
EDITOR=vim
