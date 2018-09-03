#!/bin/bash

if [ ! -d ~/.vim/bundle/Vundle.vim ]; then
    git clone --depth=1 https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
fi

if [ ! "$(grep vundle.vim ~/.vimrc)" ]; then
    cat ~/.vimrc | sed '3i \
source ~/.dots/vim/vundle.vim
' > /tmp/vimrc.tmp
    mv /tmp/vimrc.tmp ~/.vimrc
fi

vim -c BundleInstall -c qa
