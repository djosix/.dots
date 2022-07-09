#!/bin/bash
#
# This script should be executed at .dots/
#

VIMRC=$HOME/.vimrc
SOURCE_VIM_PLUG=$HOME/.dots/vim/plug.vim
TARGET_VIM_PLUG=$HOME/.vimrc.plug

[[ -e $TARGET_VIM_PLUG ]] || (
    echo "@@@ Copying $SOURCE_VIM_PLUG to $TARGET_VIM_PLUG"
    set -x
    cp $SOURCE_VIM_PLUG $TARGET_VIM_PLUG
)

NEW_LINE="source $TARGET_VIM_PLUG"
PLACEHOLDER='" {PLACEHOLDER}'

[[ ! `grep -F "$NEW_LINE" $VIMRC` && `grep -F "$PLACEHOLDER" $VIMRC` ]] && (
    echo "@@@ Adding vim-plug source line to $VIMRC (because '$PLACEHOLDER' exists)"
    set -x
    TEMP_FILE="$(mktemp)"
    sed "s|$PLACEHOLDER|$NEW_LINE\n$PLACEHOLDER|" $VIMRC > $TEMP_FILE
    mv $TEMP_FILE $VIMRC
)

[[ `grep -F "$NEW_LINE" $VIMRC` ]] && (
    echo '@@@ Installing VIM plugins'
    set -x
    vim -c PlugInstall -c qa!
)
