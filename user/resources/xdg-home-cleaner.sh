#!/bin/bash

directories=("Downloads" "go" "Bitwig Studio" "Desktop")

inotifywait -m --format '%w%f' -e create "$HOME/" | while read -r path; do
    for dir in "${directories[@]}"; do
        if [[ "$path" == "$HOME/$dir" ]]; then
            rm -rf "$path"
            echo "Deleted: $path"
        fi
    done
done
