#!/bin/bash
#
# This script should be executed at .dots/
#

vimrc=~/.vimrc
vundle_vim_inc=~/.dots/vim/vundle.vim
vundle_repo=https://github.com/VundleVim/Vundle.vim.git
vundle_dst=~/.vim/bundle/Vundle.vim


if [ ! -d $vundle_dst ]; then
    echo "@@@ Install Vundle from $vundle_repo"
    git clone --depth=1 $vundle_repo $vundle_dst
fi

if [ ! "$(grep vundle.vim $vimrc)" ]; then
    echo "@@@ Adding Vundle script to $vimrc"
    tmpfile=/tmp/__vimrc_tmpfile
    cat $vimrc | sed $'3i \\\nsource '"$vundle_vim_inc"$'\n' > $tmpfile
    mv $tmpfile $vimrc
fi

echo '@@@ Installing Vundle plugins'
vim -c BundleInstall -c qa
