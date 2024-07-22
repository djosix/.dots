#!/bin/bash

#source $HOME/.dots/zsh/mouse.zsh && zle-toggle-mouse

if command_exists "brew"; then
    export HOMEBREW_NO_AUTO_UPDATE="1"
fi

#PATH=":$PATH"
#PATH=":$PATH"
export PATH

#zstyle ':omz:update' mode disabled

rbenv() {
    [ -d "$HOME/.rbenv" ] || get-rbenv
    unset -f rbenv
    export PATH="$HOME/.rbenv/bin:$PATH"
    eval "$(rbenv init -)"
    rbenv "$@"
}

nvm() {
    [[ -d "$HOME/.nvm" ]] || {
        curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh" | bash
    }
    unset -f "nvm"
    export NVM_DIR="$HOME/.nvm"
    [[ -s "$NVM_DIR/nvm.sh" ]] && {
        \. "$NVM_DIR/nvm.sh"  # This loads nvm
    }
    [[ -s "$NVM_DIR/bash_completion" ]] && {
        \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
    }
    if [[ "$*" ]]; then nvm "$@"; else nvm current; fi
}
nvm_lazy_load_func_def='{ hash $0 || nvm; } >& /dev/null && unset -f "$0" && command "$0" "$@"'
eval "node() { $nvm_lazy_load_func_def; }"
eval "yarn() { $nvm_lazy_load_func_def; }"
eval "npm() { $nvm_lazy_load_func_def; }"
eval "npx() { $nvm_lazy_load_func_def; }"
unset nvm_lazy_load_func_def
