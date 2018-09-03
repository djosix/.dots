#/bin/bash -x

dir=$1 # current dir
omz=$2 # oh my zsh path

if [ ! -d $omz ]; then
    echo 'OMZ not found, cloning...'
    git clone --depth=1 https://github.com/robbyrussell/oh-my-zsh.git $omz
fi

# cmd prompt
echo "link: $omz/themes/djosix.zsh-theme -> $dir/zsh/djosix.zsh-theme"
ln -sf $dir/zsh/djosix.zsh-theme $omz/themes/djosix.zsh-theme

# zshrc
template=$omz/templates/zshrc.zsh-template
cat $template | sed "/^export ZSH=/ c\\
export ZSH=$omz
" | sed "/^ZSH_THEME=/ c\\
ZSH_THEME=\"djosix\"
" | sed "/^# DISABLE_AUTO_UPDATE/ c\\
DISABLE_AUTO_UPDATE=\"true\"
" > ~/.zshrc
echo "create: ~/.zshrc (from $template)"

# zshlocal
if [ ! -f ~/.zshlocal ]; then
    echo "copy: $dir/zsh/local.zsh -> ~/.zshlocal"
    cp $dir/zsh/local.zsh ~/.zshlocal
fi

# includes
inc="
# .dots
source $dir/zsh/ls_colors.zsh
source $dir/zsh/config.zsh
source ~/.zshlocal
"
echo "append: ($inc) -> ~/.zshrc"
echo "$inc" >> ~/.zshrc
