#!/bin/bash

if [ ! -d ~/.vim/bundle/Vundle.vim ]; then
    git clone --depth=1 https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
fi

if [ ! "$(grep vundle.vim ~/.vimrc)" ]; then
    echo 'source ~/.dots/vim/vundle.vim' >> ~/.vimrc
fi

vim -c BundleInstall -c qa
