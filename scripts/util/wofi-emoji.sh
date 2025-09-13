#!/bin/bash

pidof wofi

if [ $? -eq 0 ]; then
    killall wofi
    exit 0
fi

cd ~/.tilekitty/dotfiles/wofi
choice="$(cat ~/.tilekitty/resources/emoji.txt | wofi --conf emoji-config)"

if [ -n "$choice" ]; then
    choice="${choice:0:1}"
    sleep 0.1
    wtype "$choice"
    wl-copy "$choice"
fi
