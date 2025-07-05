#!/bin/sh

hyprctl activewindow | grep "floating: 1"

if [ $? -eq 0 ]; then
    hyprctl dispatch settiled
else
    hyprctl dispatch setfloating
    hyprctl dispatch resizeactive exact 48% 56%
    hyprctl dispatch centerwindow
fi
