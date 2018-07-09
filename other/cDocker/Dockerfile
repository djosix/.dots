FROM ubuntu:xenial
RUN apt update; \
    apt upgrade -y
RUN apt install -y \
    python python-dev python-pip \
    python3 python3-dev python3-pip \
    htop tmux git zsh gcc g++ make \
    cmake binutils curl wget netcat \
    vim zip unzip locales
RUN pip install -U pip; \
    sed -i 's/from pip import main/from pip._internal import main/' /usr/bin/pip; \
    pip install pwntools ipython; \
    pip3 install -U pip; \
    sed -i 's/from pip import main/from pip._internal import main/' /usr/bin/pip3; \
    pip3 install git+https://github.com/arthaud/python3-pwntools.git ipython
RUN cd /root && git clone https://github.com/djosix/.dots.git; \
    cd .dots && make all && make git && locale-gen en_US.UTF-8; \
    chsh -s /usr/bin/zsh; \
    bash -c 'history -c'
CMD zsh
