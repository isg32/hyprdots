#!/usr/bin/env bash
# prints true/false for the toggle's current state
case "$1" in
  wifi)       [ "$(nmcli radio wifi)" = enabled ] && echo true || echo false ;;
  bluetooth)  bluetoothctl show 2>/dev/null | grep -q 'Powered: yes' && echo true || echo false ;;
  nightlight) t=$(hyprctl hyprsunset temperature 2>/dev/null | tr -dc 0-9); [ -n "$t" ] && [ "$t" -lt 6000 ] && echo true || echo false ;;
  powersaver) [ "$(powerprofilesctl get)" = power-saver ] && echo true || echo false ;;
esac
