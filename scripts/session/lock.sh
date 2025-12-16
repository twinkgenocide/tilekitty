#!/bin/sh

source ~/.tilekitty/env.sh

swaync-client -C # close all notifications
play_sound dialog-warning.ogg
hyprlock
play_sound bell.ogg
