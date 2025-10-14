#!/bin/bash

source ~/.tilekitty/env.sh

pidof wofi

if [ $? -eq 0 ]; then
    killall wofi
    exit 0
fi

cd ~/.tilekitty/dotfiles/wofi
choice="$(cat $TK_RES/user/emoji.txt | wofi --conf emoji/config)"

if [ -n "$choice" ]; then
    choice="$(echo "$choice" | cut -d' ' -f1)"
    wl-copy "$choice"

    play_sound message.ogg
    notify-send -u low -i "emoji-symbols-symbolic" "Emoji picker" "$choice copied to clipboard."
fi
