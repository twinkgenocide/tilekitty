TK="$HOME/.tilekitty"
TK_RES="$TK/resources"
TK_BIN="$TK/binaries"

play_sound() {
    paplay $TK_RES/sound/$1 &
}
