#!/usr/bin/env bash
# usage: toggle.sh <wifi|bluetooth|nightlight|powersaver|dnd> ; SWAYNC_TOGGLE_STATE=true|false (new state)
on=$([ "$SWAYNC_TOGGLE_STATE" = true ] && echo 1 || echo 0)
case "$1" in
  wifi)       nmcli radio wifi $([ $on = 1 ] && echo on || echo off) ;;
  bluetooth)  if [ $on = 1 ]; then rfkill unblock bluetooth; bluetoothctl power on; else bluetoothctl power off; fi ;;
  nightlight) hyprctl hyprsunset temperature 3500 >/dev/null 2>&1; [ $on = 1 ] || hyprctl hyprsunset identity >/dev/null 2>&1
              [ $on = 1 ] && hyprctl hyprsunset temperature 3500 >/dev/null ;;
  powersaver) ~/.config/hypr/scripts/powermode.sh $([ $on = 1 ] && echo saver || echo balanced) ;;
esac
