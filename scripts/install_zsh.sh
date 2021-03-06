#!/bin/bash
#
# This script should be executed at .dots/
#

omz=~/.omz
omz_repo=https://github.com/robbyrussell/oh-my-zsh.git

zsh_theme_src=zsh/djosix.zsh-theme
zsh_theme=$omz/themes/djosix.zsh-theme

zshrc_src=zsh/config.zsh
zshrc_tpl=$omz/templates/zshrc.zsh-template
zshrc=~/.zshrc

zshrc_local_src=zsh/local.zsh
zshrc_local=~/.zshrc.local

dots=~/.dots


#
# oh my zsh
#
echo "@@@ Installing oh-my-zsh from $omz_repo"
rm -rf $omz
git clone --depth 1 $omz_repo $omz

#
# command prompt theme
#
echo "@@@ Linking $zsh_theme -> $zsh_theme_src"
ln -sf $dots/$zsh_theme_src $zsh_theme

#
# zsh plugins
#
echo "@@@ Installing ZSH plugins"
git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions $omz/custom/plugins/zsh-autosuggestions
git clone --depth 1 https://github.com/zsh-users/zsh-completions $omz/custom/plugins/zsh-completions

#
# zshrc
#
echo "@@@ Creating $zshrc from $zshrc_tpl"
cat $zshrc_tpl | sed "/^export ZSH=/ c\\
export ZSH=\"$omz\"
" | sed "/^ZSH_THEME=/ c\\
ZSH_THEME=\"djosix\"
" | sed "/^# DISABLE_AUTO_UPDATE/ c\\
DISABLE_AUTO_UPDATE=\"true\"
" | sed $'/^plugins=/ c\\
plugins=\\(zsh-autosuggestions zsh-completions)
' > $zshrc

inc="
#
# .dots
#
source $dots/$zshrc_src
source $zshrc_local
"
echo "@@@ Appending .dots sources to $zshrc"
echo "$inc" >> $zshrc

#
# zshrc.local user config
#
if [ ! -f $zshrc_local ]; then
    echo "@@@ Copying $zshrc_local_src to $zshrc_local"
    cp $zshrc_local_src $zshrc_local
fi
