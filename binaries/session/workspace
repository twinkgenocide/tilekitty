#!/bin/sh

ACTION=$1
TARGET_WS=$2

# Get active workspace IDs excluding special workspaces
ACTIVE_WS=$(hyprctl workspaces | grep -v 'special:' | grep -oP 'workspace ID \K\d+')

function help() {
    echo "Usage: workspace {switch|movewindow} <workspace_id>"
}

function workspace_exists() {
    echo "$ACTIVE_WS" | grep -qx "$1"
}

if [[ -z "$ACTION" || -z "$TARGET_WS" ]]; then
    help
    exit 1
fi

if ! workspace_exists "$TARGET_WS"; then
    echo "Workspace $TARGET_WS does not exist."
    exit 1
fi

case $ACTION in
    switch)
        hyprctl dispatch workspace "$TARGET_WS"
        ;;
    movewindow)
        hyprctl dispatch movetoworkspace "$TARGET_WS"
        ;;
    *)
        help
        exit 1
        ;;
esac

