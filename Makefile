#
# Author: Yuankui Lee @ 2019.04.30
# https://github.com/djosix/.dots
#

GIT_NAME = djosix
GIT_MAIL = djosicks@gmail.com


.PHONY: default base more all
.PHONY: bash zsh vim tmux git vim_plug dirs
.PHONY: update reset

default:
	@sed '/```/d;1,/<!--BeginUsage-->/d;/<!--EndUsage-->/,$$d' README.md

base: bash zsh vim tmux
more: git vim_plug dirs
all: base more

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

vim_plug:
	@echo '===> vim plug'
	@scripts/install_vim_plug.sh

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

update:
	@echo '===> update'
	git add -A
	git pull --rebase --autostash origin master

discard:
	@echo '===> discard'
	git add -A
	git reset --hard origin/master

cleanup:
	@echo '===> cleanup'
	@rm -rfv backup/*
