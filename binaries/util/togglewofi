#!/bin/sh

pidof wofi

if [ $? -eq 0 ]; then
    killall wofi
else
    wofi "$@"
fi
