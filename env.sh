#/usr/bin/env bash

TK="$HOME/.tilekitty"
TK_RES="$TK/resources"
TK_BIN="$TK/scripts"

play_sound() {
    paplay $TK_RES/sound/$1 &
}
