#!/bin/sh

docker build -t pwn .

echo "
Add this to your shell config:

    alias pwn='docker run -it --rm -v \$PWD:/root/currdir -w /root/currdir pwn zsh'

"
