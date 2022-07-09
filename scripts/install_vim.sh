#!/bin/bash
#
# This script should be executed at .dots/
#

SOURCE_VIMRC=$PWD/vim/vimrc.vim
SOURCE_VIMRC_LOCAL=$PWD/vim/local.vim
SOURCE_VIM_DIR=$PWD/vim/vim

TARGET_VIMRC=$HOME/.vimrc
TARGET_VIMRC_LOCAL=$HOME/.vimrc.local
TARGET_VIM_DIR=$HOME/.vim

PLACEHOLDER_LINE='" {PLACEHOLDER}'

echo "@@@ Writing $TARGET_VIMRC"
cat <<EOF >$TARGET_VIMRC
" THIS FILE IS MANAGED BY SCRIPTS
" CONSIDER ADDING LOCAL CONFIGURATION TO $TARGET_VIMRC_LOCAL
source $SOURCE_VIMRC
$PLACEHOLDER_LINE
source $TARGET_VIMRC_LOCAL " your local config should be here
EOF

if [[ ! -e $TARGET_VIMRC_LOCAL ]]; then
    echo "@@@ Copying $SOURCE_VIMRC_LOCAL to $TARGET_VIMRC_LOCAL (because it doesn't exist)"
    cp $SOURCE_VIMRC_LOCAL $TARGET_VIMRC_LOCAL
fi

echo "@@@ Copying $SOURCE_VIM_DIR to $TARGET_VIM_DIR"
cp -R $SOURCE_VIM_DIR $TARGET_VIM_DIR
