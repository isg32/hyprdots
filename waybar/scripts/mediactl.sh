#!/usr/bin/env bash
# mediactl.sh <playerctl args...>  — run a playerctl command, then refresh the media modules immediately
playerctl "$@" 2>/dev/null
sleep 0.12                       # let the player publish its new state
pkill -RTMIN+9 waybar
