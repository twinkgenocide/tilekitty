#!/bin/sh

source ~/.tilekitty/env.sh

if pidof -o %PPID -x "power" ; then
    exit 1
fi

help() {
    echo "usage: power (logoff|shutdown|reboot) [ask]"
}

ACTION="$1"
ASK="$2"

ask_first() {
    play_sound message.ogg
    RESULT=$(notify-send -i power-symbolic -u critical -A yes="Yes" -A no="No" "Proceed with ${ACTION^}?")
    if [ "$RESULT" == "no"  ]; then
        play_sound bell.ogg
        exit 1
    fi
}

fade_out() {
    if [ "$ASK" == "ask" ]; then
        ask_first
    fi
    play_sound desktop-logoff.ogg
    sleep 1
    $TK_BIN/util/fade.sh out &
    sleep 1.0
    hyprctl dispatch dpms off
    sleep 3.0
}

case "$ACTION" in
    logoff)
        fade_out
        hyprctl dispatch exit 1
        ;;
    shutdown)
        fade_out
        systemctl poweroff
        ;;
    reboot)
        fade_out
        systemctl reboot
        ;;
    *)
        help
        exit
        ;;
esac
