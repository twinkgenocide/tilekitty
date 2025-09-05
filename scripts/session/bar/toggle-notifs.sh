#!/bin/bash

STATUS="$(swaync-client -D | grep -q 'true' && echo on || echo off)"

if [ "$STATUS" = "on" ]; then
    echo '{"text": "󱏫", "class": "dnd"}' | jq --unbuffered --compact-output
else
    echo '{"text": "󰂚"}' | jq --unbuffered --compact-output
fi
