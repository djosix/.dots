## Dotfiles for Linux and macOS

- Available targets: `make`
  <!--BeginUsage-->
  ```
  Select targets to run:

    bash          Install bash config files
    zsh           Install zsh config files
    vim           Install vim config files
    tmux          Install tmux config file

    git           Setup name and email for Git
    vim_plug      Install plugins using Plug
    dirs          Create useful directories

    base          [bash, zsh, vim, tmux]
    more          [git, vim_plug, dirs]
    all           [base, more]

    update        Discard and update
    discard       Discard changes in .dots
    cleanup       Remove backup files
  
  ```
  <!--EndUsage-->

- Quick install

  ```shell
  cd
  git clone https://github.com/djosix/.dots.git
  cd .dots
  make all
  ```
