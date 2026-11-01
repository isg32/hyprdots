#!/usr/bin/env bash
pkill -x rofi && exit 0
opts="  Lock\n󰍃  Logout\n󰤄  Suspend\n󰒲  Hibernate\n  Reboot\n  Shutdown"
choice="$(printf "$opts" | rofi -dmenu -i -p "Power" -theme "$HOME/.config/rofi/powermenu.rasi")"
case "$choice" in
  *Lock)      loginctl lock-session ;;
  *Logout)    command -v hyprshutdown >/dev/null && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()' ;;
  *Suspend)   systemctl suspend ;;
  *Hibernate) systemctl hibernate ;;
  *Reboot)    systemctl reboot ;;
  *Shutdown)  hyprshutdown -t "Shutting down…" --post-cmd "systemctl poweroff" 2>/dev/null || systemctl poweroff ;;
esac
