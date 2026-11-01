#!/usr/bin/env bash
pkill -x rofi && exit 0
cliphist list | rofi -dmenu -p "󰅍 Clipboard" -theme-str 'window {width: 640px;}' | cliphist decode | wl-copy
