# djosix 2018/08/25

ZSH_OMZ = ~/.oh-my-zsh
GIT_NAME = djosix
GIT_MAIL = djosicks@gmail.com

DIR = $(shell pwd)


.PHONY: default part all bash zsh vim tmux git vundle dirs update reset

default:
	@echo '------ targets ------'
	@echo 'bash'
	@echo 'zsh'
	@echo 'vim'
	@echo 'tmux'
	@echo 'part (bash, zsh, vim, tmux)'
	@echo 'git'
	@echo 'vundle - vim plugins'
	@echo 'dirs'
	@echo 'all (bash, zsh, vim, tmux, git, vundle, dirs)'
	@echo 'update - discard and update'
	@echo 'discard - discard changes in .dots'

part: bash zsh vim tmux

all: bash zsh vim tmux git vundle dirs

bash:
	@echo '------ bash ------'
	backup/backup.sh ~/.bashrc ~/.bash_profile ~/.bash_logout
	rm -rf ~/.bashrc ~/.bash_profile ~/.bash_logout
	cp bash/bashrc.sh ~/.bashrc
	cp bash/bash_profile.sh ~/.bash_profile
	cp bash/bash_logout.sh ~/.bash_logout

zsh:
	@echo '------ zsh ------'
	backup/backup.sh ~/.zshrc
	rm -rf ~/.zshrc
	zsh/install.sh $(DIR) $(ZSH_OMZ)

vim:
	@echo '------ vim ------'
	backup/backup.sh ~/.vimrc ~/.vim
	rm -rf ~/.vim ~/.vimrc
	echo 'source ~/.dots/vim/vimrc.vim' > ~/.vimrc
	cp -r vim/vim ~/.vim

vundle:
	@echo '------ vundle ------'
	backup/backup.sh ~/.vimrc ~/.vim
	vim/vundle.sh

git:
	@echo '------ git ------'
	git config --global user.name $(GIT_NAME)
	git config --global user.email $(GIT_MAIL)

tmux:
	@echo '------ tmux ------'
	backup/backup.sh ~/.tmux.conf
	rm -rf ~/.tmux.conf
	cp tmux/tmux.conf ~/.tmux.conf

dirs:
	@echo '------ dirs ------'
	test -d ~/Space || mkdir ~/Space
	test -d ~/.bin || mkdir ~/.bin

update: discard
	@echo '------ update ------'
	git pull origin master

discard:
	@echo '------ discard ------'
	git add -A
	git reset --hard origin/master
