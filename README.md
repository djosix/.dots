## Dotfiles for Linux and macOS

- Available targets: `make`

  ```
  Select targets to run:

    bash              Install zsh config files
    zsh               Install zsh config files
    vim               Install vim config files
    tmux              Install tmux config file

    git               Setup name and email for Git
    vundle            Install Vundle and my plugins
    dirs              Create useful directories

    part (bash, zsh, vim, tmux)
    all (bash, zsh, vim, tmux, git, vundle, dirs)

    update            Discard and update
    discard           Discard changes in .dots
    remove_backups    Remove backup files
  ```

- Quick install

  ```shell
  cd
  git clone https://github.com/djosix/.dots.git
  cd .dots
  make all
  ```
