#PATH=":$PATH"
#export PATH

#rbenv() {
#    [ -d "$HOME/.rbenv" ] || get-rbenv
#    unset -f rbenv
#    export PATH="$HOME/.rbenv/bin:$PATH"
#    eval "$(rbenv init -)"
#    rbenv $@
#}

#nvm() {
#    [ -d "$HOME/.nvm" ] || curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash
#    unset -f nvm
#    export NVM_DIR="$HOME/.nvm"
#    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
#    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
#    nvm $@
#}
