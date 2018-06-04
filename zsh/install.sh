# Djosix 2017.05.30

DIR=$1
ZSH=$2

test -d $ZSH && exit 1

# Download
git clone --depth=1 https://github.com/robbyrussell/oh-my-zsh.git $ZSH

# zshrc
TEMPLATE=$ZSH/templates/zshrc.zsh-template
cat $TEMPLATE | sed "/^export ZSH=/ c\\
export ZSH=$ZSH
" | sed "/^ZSH_THEME=/ c\\
ZSH_THEME=\"djosix\"
" | sed "/^# DISABLE_AUTO_UPDATE/ c\\
DISABLE_AUTO_UPDATE=\"true\"
" > ~/.zshrc

# Dot zshrc, local zshrc and ls colors
echo "
# .dots
source $DIR/zsh/ls_colors.zsh
source ~/.dotzsh
source ~/.zshlocal
" >> ~/.zshrc
[ -f ~/.zshlocal ] || cp $DIR/zsh/local.zsh ~/.zshlocal
