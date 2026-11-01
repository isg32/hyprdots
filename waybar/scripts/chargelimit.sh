#!/usr/bin/env bash
# chargelimit.sh [status|toggle|on|off] — Lenovo conservation mode ("battery preserve": stops charging at ~60%)
f=$(ls /sys/bus/platform/drivers/ideapad_acpi/VPC*/conservation_mode 2>/dev/null | head -1)
helper=/usr/local/bin/battery-conservation
state() { [ -n "$f" ] && [ "$(cat "$f" 2>/dev/null)" = 1 ]; }
set_mode() {
  if ! sudo -n "$helper" "$1" >/dev/null 2>&1; then
    notify-send -a "Battery" -u normal "Charge limit needs one-time setup" "Run:  bash ~/.config/hypr/setup/3-battery-conservation.sh"; exit 1
  fi
  sleep 0.2; pkill -RTMIN+11 waybar
  if state; then notify-send -a "Battery" "Battery preserve: ON" "Charging is limited to about 60% to protect the battery."
  else notify-send -a "Battery" "Battery preserve: OFF" "Charging to 100% again."; fi
}
case "${1:-status}" in
  toggle) if state; then set_mode off; else set_mode on; fi ;;
  on)  set_mode on ;;
  off) set_mode off ;;
  *)
    [ -n "$f" ] || exit 0                                   # unsupported hardware: module hides
    cap=$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null)
    if state; then
      printf '{"text":"%s","class":"on","tooltip":"Battery preserve: ON\\nCharging stops at about 60%% (now %s%%)\\nClick to charge fully"}\n' "$(printf '\U000F0565')" "$cap"
    else
      printf '{"text":"%s","class":"off","tooltip":"Battery preserve: off\\nClick to limit charging to about 60%% and protect the battery"}\n' "$(printf '\U000F0565')"
    fi ;;
esac
