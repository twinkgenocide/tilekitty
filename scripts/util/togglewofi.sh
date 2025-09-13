#!/bin/sh

pidof wofi

if [ $? -eq 0 ]; then
    killall wofi
else
    cd ~/.tilekitty/dotfiles/wofi
    wofi "$@"
fi
