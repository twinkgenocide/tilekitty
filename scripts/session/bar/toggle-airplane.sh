#!/bin/bash

toggle_on() {
    nmcli device status | awk '$2 == "ethernet" {print $1}' | xargs -r -n1 nmcli -w 1 device disconnect
    nmcli radio all off
}

toggle_off() {
    nmcli device status | awk '$2 == "ethernet" {print $1}' | xargs -r -n1 nmcli -w 1 device connect
    nmcli radio all on
}

if nmcli radio all | tr ' ' '\n' | grep -v '^missing$' | grep -q '^enabled$'; then
    toggle_on >/dev/null
else
    toggle_off >/dev/null
fi
