#!/bin/sh

hyprctl reload
pkill waybar
hyprctl dispatch exec waybar
