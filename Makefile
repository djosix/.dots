# Djosix 2017 06 30

# zsh
ZSH = ~/.oh-my-zsh

# git
GIT_NAME = djosix
GIT_MAIL = djosicks@gmail.com


DIR = $(shell pwd)
UNAMEN = $(shell uname -n)

.PHONY: default vim git bash zsh tmux other update reset all

default:
	@echo Select one to config

bash:
	@echo 'Setting up bash...'
	@ln -sf $(DIR)/bash/bash_profile.sh ~/.bash_profile
	@ln -sf $(DIR)/bash/bash_logout.sh ~/.bash_logout
	@rm -f ~/.bashrc
	@cp $(DIR)/bash/bashrc.sh ~/.bashrc

zsh:
	@echo 'Setting up zsh...'
	@sh $(DIR)/zsh/install.sh $(DIR) $(ZSH) || echo 'Skip installing Oh My Zsh'
	@ln -sf $(DIR)/zsh/djosix.zsh-theme $(ZSH)/themes/djosix.zsh-theme
	@ln -sf $(DIR)/zsh/config.zsh ~/.dotzsh
	@[ -f ~/.zshlocal ] || cp $(DIR)/zsh/local.zsh ~/.zshlocal

vim:
	@echo 'Setting up vim...'
	@rm -rf ~/.vim ~/.vimrc
	@ln -sf $(DIR)/vim/vimrc ~/.vimrc
	@ln -sf $(DIR)/vim/vim ~/.vim

git:
	@echo 'Setting up git...'
	@git config --global user.name $(GIT_NAME)
	@git config --global user.email $(GIT_MAIL)

tmux:
	@echo 'Copying tmux settings...'
	@cp -f tmux/tmux.conf ~/.tmux.conf

other:
	@echo 'Setting up my directories...'
	@[ -d ~/Space ] || mkdir ~/Space
	@[ -d ~/.bin ] || mkdir ~/.bin

update: reset
	@echo 'Updating...'
	@git pull origin master

reset:
	@echo 'Reseting...'
	@git add -A
	@git reset --hard HEAD

all: bash zsh vim other
	@echo Done
