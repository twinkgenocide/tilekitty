#!/bin/sh

source ~/.tilekitty/env.sh

PARAMS="-c $TK_RES/snippets/hyprlock-fade.conf"

fade_in() {
    sleep 1.5
    pkill -USR1 hyprlock
    if [ "$1" == "sound" ]; then
        /usr/local/bin/tilekitty/playsound desktop-login.ogg
        sleep 0.1
    fi
}

case $1 in
"in")
    PARAMS="$PARAMS --no-fade-in"
    fade_in $2 &
    ;;
"out")
    :
    ;;
*)
    echo "usage: fade (in|out) [sound]"
    exit 1
    ;;
esac

hyprlock $PARAMS
