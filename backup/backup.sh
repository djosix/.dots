#!/bin/bash

backup_dir=backup

for path in "$@"; do
    prefix="backup@$(date +%Y%m%d%H%M%S)"
    name="$(basename $path)"
    backup_path="$backup_dir/$prefix-$name"
    if [[ ( -f $path || -d $path ) && ! -L $path ]]; then
        cp -r $path $backup_path
        echo backup: $path '->' $backup_path
    fi
done
