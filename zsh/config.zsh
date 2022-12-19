#!/bin/bash

function command_exists() {
    command -v "$1" >/dev/null 2>&1
}

#===============================================
# Environment
#===============================================

# ls color
export LS_COLORS='rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=00:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arc=01;31:*.arj=01;31:*.taz=01;31:*.lha=01;31:*.lz4=01;31:*.lzh=01;31:*.lzma=01;31:*.tlz=01;31:*.txz=01;31:*.tzo=01;31:*.t7z=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.dz=01;31:*.gz=01;31:*.lrz=01;31:*.lz=01;31:*.lzo=01;31:*.xz=01;31:*.zst=01;31:*.tzst=01;31:*.bz2=01;31:*.bz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.war=01;31:*.ear=01;31:*.sar=01;31:*.rar=01;31:*.alz=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.cab=01;31:*.wim=01;31:*.swm=01;31:*.dwm=01;31:*.esd=01;31:*.jpg=01;35:*.jpeg=01;35:*.mjpg=01;35:*.mjpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.webm=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.m4a=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.oga=00;36:*.opus=00;36:*.spx=00;36:*.xspf=00;36:'
export LSCOLORS=Exfxcxdxbxegedabagacad

# PATH
export PATH="$HOME/.dots/bin:$PATH"
if [[ -d $HOME/.bin ]]; then
    export PATH="$HOME/.bin:$PATH"
fi

# locale
export LC_CTYPE="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
export LANG="en_US.UTF-8"
export LANGUAGE="en_US.UTF-8"

# EDITOR
if command_exists "vim"; then
    export EDITOR="vim"
fi

# GOPATH
if command_exists "go" && test -d "$HOME/.go"; then
    export GOPATH="$HOME/.go"
fi

#===============================================
# Aliases and shortcuts
#===============================================

# ls
alias l='ls -F'
alias la='ls -alh'
alias ll='ls -lh'

# cd
alias cs='cd "$HOME/Space"; :'
alias cdd='cd "$HOME/Desktop"; :'
alias cdl='cd "$HOME/Downloads"; :'
alias cdt='cd "$HOME/Tools"; :'
alias cdc='cd "$HOME/Documents"; :'
alias cdb='cd "$HOME/Dropbox"; :'
alias cds='cd "$HOME/Dropbox/Space"; :'
alias tmp='mkdir -p "/tmp/$USER"; cd "/tmp/$USER"; :'

# youtube-dl
if command_exists "youtube-dl"; then
    alias youtube-dl-brute='youtube-dl --ignore-errors --download-archive .youtube-dl'
    alias youtube-dl-mp3='youtube-dl -x --audio-format mp3'
    alias youtube-dl-mp3-brute='youtube-mp3 --ignore-errors --download-archive .youtube-dl'
fi

# disk
alias du="du -h"
alias df="df -h"

# docker
function dr() {
    local workdir="/root/workdir"
    docker run -it --rm -v "$PWD:$workdir" -w "$workdir" "$@"
}
function drs() {
    dr --cap-add=SYS_PTRACE --security-opt seccomp=unconfined "$@"
}

# other
function findname() { find . -name "*$1*"; }
function lesser() {
    less -S --shift 8 "$@"
}
function date() {
    case "$1" in
    s|sec|secs|second|seconds)
        shift; command date +'%s' "$@" ;;
    p|print)
        shift; command date +'%Y-%m-%d %H:%M:%S' "$@" ;;
    c|compact)
        shift; command date +'%Y%m%d%H%M%S' "$@" ;;
    r|R|tz|TZ|rfc|RFC|rfc3339|RFC3339)
        shift; command date -u +"%Y-%m-%dT%H:%M:%SZ" "$@" ;;
    i|I|iso|ISO|iso8601|ISO8601)
        shift; command date +"%Y-%m-%dT%H:%M:%S%:z" "$@" ;;
    *)  command date "$@" ;;
    esac
}

# git
function ga      { command git add "$@"; }
function gaa     { command git add -A; }
function gau     { command git add -u "$@"; }
function gst     { command git status "$@"; }
function glg     { command git log "$@"; }
function glgg    { command git log --all --decorate --oneline --graph "$@"; }
function ggi     { command git init "$@"; }
function gra     { command git remote add "$@"; }
function gcm     { command git commit -m "$@"; }
function gct     { command git commit -m "$(date +"Commit %Y/%m/%d %H:%M:%S")"; }
function gcl     { command git clone "$@"; }
function gcl1    { command git clone --depth 1 "$@"; }
function gck     { command git checkout "$@"; }
function gbh     { command git branch "$@"; }
function gbc     { command git branch --show-current; }
function gpsh    { command git push "$@"; }
function gpom    { command git push origin "$(gbc)" "$@"; }
function ggg     { gaa && gct && gpom; }
function gpl     { command git pull "$@"; }
function gplom   { command git pull origin "$(gbc)"; }
function gplomar { command git pull origin "$(gbc)" --autostash --rebase; }
function grst    { command git reset "$@"; }

function int {
    local code="$?"
    if [[ $# -gt 0 ]]; then
        "$@"
        local code="$?"
    fi
    echo "$code"
    return "$code"
}

function bool {
    local code="$?"
    if [[ $# -gt 0 ]]; then
        "$@"
        local code="$?"
    fi
    (( code == 0 )) && echo true || echo false
    return "$code"
}

#
# Native aliases
#
case "$(uname)" in
    Linux)
        alias ls="ls --color=auto"
        alias dfc='df -h -x{overlay,tmpfs,squashfs,devtmpfs}' # df clean
        test -d "/dev/shm" && function ram {
            mkdir -p "/dev/shm/$USER"
            cd "/dev/shm/$USER" || return
        }
        ;;

    Darwin)
        alias ls="ls -G"
        alias trash=_mac_move_to_trash
        alias dds="find . -name .DS_Store -exec rm -v {} +"
        ;;
esac
