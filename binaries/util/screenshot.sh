#!/bin/sh

source ~/.tilekitty/env.sh

pgrep slurp
if [ $? -eq 0 ]; then
    exit
fi

if [[ $1 == s ]]; then
    play_sound screen-capture.ogg &
    grim - | wl-copy
fi

if [[ $1 == r ]]; then
    REGION="$(slurp -b 000000a0 -c ffffff -w 0 -F Iosevka -d)"
    RESULT=$?

    if [ $RESULT -eq 0 ]; then
        play_sound screen-capture.ogg &
        grim -g "$REGION" - | wl-copy
    fi
fi
