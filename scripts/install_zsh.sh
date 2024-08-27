#!/bin/bash
#
# This script should be executed at .dots/
#

set -e

dots_dir="$HOME/.dots"

omz_dir="$HOME/.omz"
omz_repo="https://github.com/robbyrussell/oh-my-zsh.git"
omz_branch="master"

zsh_theme_src="$dots_dir/zsh/djosix.zsh-theme"
zsh_theme="$omz_dir/themes/djosix.zsh-theme"

zshrc_src="$dots_dir/zsh/config.zsh"
zshrc_tpl="$omz_dir/templates/zshrc.zsh-template"
zshrc="$HOME/.zshrc"

zshrc_local_src="$dots_dir/zsh/local.zsh"
zshrc_local="$HOME/.zshrc.local"



#
# oh my zsh
#
echo "@@@ Installing oh-my-zsh from $omz_repo"
rm -rf "$omz_dir"
git clone --depth 1 --branch "$omz_branch" --single-branch "$omz_repo" "$omz_dir"

#
# command prompt theme
#
echo "@@@ Linking $zsh_theme -> $zsh_theme_src"
ln -sf "$zsh_theme_src" "$zsh_theme"

#
# zsh plugins
#
echo "@@@ Installing ZSH plugins"
git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions "$omz_dir/custom/plugins/zsh-autosuggestions"
git clone --depth 1 https://github.com/zsh-users/zsh-completions "$omz_dir/custom/plugins/zsh-completions"

#
# zshrc
#
echo "@@@ Creating $zshrc from $zshrc_tpl"
(set -x;
sed "/^export ZSH=/ c\\
export ZSH=\"$omz_dir\"
" | sed '/^ZSH_THEME=/ c\
ZSH_THEME="djosix"
' | sed "/^# zstyle ':omz:update' mode disabled/ c\\
zstyle ':omz:update' mode disabled
" | sed $'/^plugins=/ c\\
plugins=\\(zsh-autosuggestions zsh-completions)
' | sed '/^# DISABLE_MAGIC_FUNCTIONS=/ c\
DISABLE_MAGIC_FUNCTIONS="true"
' | sed '/^# HIST_STAMPS=/ c\
HIST_STAMPS="yyyy-mm-dd"
') < "$zshrc_tpl" > "$zshrc"

echo "@@@ Appending .dots sources to $zshrc"
echo "
#
# .dots
#
source '$zshrc_src'
source '$zshrc_local'
" >> "$zshrc"

#
# zshrc.local user config
#
if [ ! -f "$zshrc_local" ]; then
    echo "@@@ Copying $zshrc_local_src to $zshrc_local"
    cp "$zshrc_local_src" "$zshrc_local"
fi
