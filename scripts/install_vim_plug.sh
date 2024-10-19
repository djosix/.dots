#!/bin/bash
#
# This script should be executed at .dots/
#

VIMRC="$HOME/.vimrc"
SOURCE_VIM_PLUG="$HOME/.dots/vim/plug.vim"
TARGET_VIM_PLUG="$HOME/.vimrc.plug"

[[ -e "$TARGET_VIM_PLUG" ]] && {
    scripts/backup.sh "$TARGET_VIM_PLUG"
}
(
    echo "@@@ Copy $SOURCE_VIM_PLUG to $TARGET_VIM_PLUG"
    set -x
    cp "$SOURCE_VIM_PLUG" "$TARGET_VIM_PLUG"
)

NEW_LINE="source $TARGET_VIM_PLUG"
PLACEHOLDER='" {PLACEHOLDER}'

[[ ! `grep -F "$NEW_LINE" "$VIMRC"` && `grep -F "$PLACEHOLDER" "$VIMRC"` ]] && (
    echo "@@@ Add vim-plug source line to $VIMRC (because '$PLACEHOLDER' exists)"
    set -x
    TEMP_FILE="$(mktemp)"
    sed "s|$PLACEHOLDER|$NEW_LINE\n$PLACEHOLDER|" "$VIMRC" > "$TEMP_FILE"
    mv "$TEMP_FILE" "$VIMRC"
)

[[ `grep -F "$NEW_LINE" "$VIMRC"` ]] && (
    echo '@@@ Install VIM plugins'
    set -x
    vim -c PlugInstall -c qa!
)
