## Dotfiles for Linux and macOS

- Available targets: `make`

  ```
  Select targets to run:

    bash          Install bash config files
    zsh           Install zsh config files
    vim           Install vim config files
    tmux          Install tmux config file

    git           Setup name and email for Git
    vundle        Install Vundle and my plugins
    dirs          Create useful directories

    part          Run bash, zsh, vim, and tmux
    all           Run bash, zsh, vim, tmux, git, vundle, and dirs

    update        Discard and update
    discard       Discard changes in .dots
    cleanup       Remove backup files

  ```

- Quick install

  ```shell
  cd
  git clone https://github.com/djosix/.dots.git
  cd .dots
  make all
  ```
