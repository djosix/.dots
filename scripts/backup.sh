#!/bin/bash
#
# This script should be executed at .dots/
#

backup_dir=backup

for path in "$@"; do
    if [[ -f $path || -d $path || -L $path ]]; then
        prefix="_$(date +%Y%m%d_%H%M%S)"
        name="$(basename $path)"
        backup_path="$backup_dir/$prefix"_"$name"
        mv $path $backup_path
        echo '@@@ Backup' $path '->' $backup_path
    fi
done
