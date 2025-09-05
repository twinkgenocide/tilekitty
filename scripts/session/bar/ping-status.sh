#!/bin/bash

sleep 0.4

if ! nmcli radio all | tr ' ' '\n' | grep -v '^missing$' | grep -q '^enabled$'; then
    # airplane mode
    echo '{"text": "󰀝", "class": "airplane"}' | jq --unbuffered --compact-output
    exit 0
fi

TARGET="1.1.1.1"

ping -c 1 -W 3 "$TARGET" >/dev/null 2>&1

case $? in
0)
    RESULT='{"text": "󰀃"}'
    ;;
1)
    RESULT='{"text": "󱔻", "class": "degraded"}'
    ;;
*)
    RESULT='{"text": "󱔑", "class": "unavailable"}'
    ;;
esac

echo "$RESULT" | jq --unbuffered --compact-output
