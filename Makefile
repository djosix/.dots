#
# Author: Yuankui Lee @ 2019.04.30
# https://github.com/djosix/.dots
#

GIT_NAME = djosix
GIT_MAIL = djosicks@gmail.com


.PHONY: default part all bash zsh vim tmux git vundle dirs update reset

default:
	@cat USAGE.txt

part: bash zsh vim tmux

all: bash zsh vim tmux git vundle dirs

bash:
	@echo '===> bash'
	@scripts/backup.sh ~/.bashrc ~/.bash_profile ~/.bash_logout
	@cp -v bash/bashrc.sh ~/.bashrc
	@cp -v bash/bash_profile.sh ~/.bash_profile
	@cp -v bash/bash_logout.sh ~/.bash_logout

zsh:
	@echo '===> zsh'
	@scripts/backup.sh ~/.zshrc
	@scripts/install_zsh.sh

vim:
	@echo '===> vim'
	@scripts/backup.sh ~/.vimrc ~/.vim
	@scripts/install_vim.sh

vundle:
	@echo '===> vundle'
	@scripts/install_vundle.sh

git:
	@echo '===> git'
	git config --global user.name $(GIT_NAME)
	git config --global user.email $(GIT_MAIL)

tmux:
	@echo '===> tmux'
	@scripts/backup.sh ~/.tmux.conf
	@cp -v tmux/tmux.conf ~/.tmux.conf

dirs:
	@echo '===> dirs'
	@test -d ~/Space || mkdir -v ~/Space
	@test -d ~/.bin || mkdir -v ~/.bin

update: discard
	@echo '===> update'
	@git pull origin master

discard:
	@echo '===> discard'
	@git add -A
	@git reset --hard origin/master

remove_backups:
	@echo '===> remove_backups'
	@rm -rfv backup/_*
