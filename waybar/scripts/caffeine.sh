#!/usr/bin/env bash
# caffeine.sh [status|toggle|on|off] — while on, the laptop won't auto-lock, blank or suspend (systemd idle+sleep inhibitor)
tag="Caffeine-waybar"
pids() { for p in $(pgrep -x systemd-inhibit); do tr '\0' ' ' < "/proc/$p/cmdline" 2>/dev/null | grep -q -- "--who=$tag" && echo "$p"; done; }
active() { [ -n "$(pids)" ]; }
on()  { active || setsid systemd-inhibit --what=idle:sleep --who="$tag" --why="Caffeine mode: keep the system awake" --mode=block sleep infinity >/dev/null 2>&1 & }
off() { for p in $(pids); do kill "$p"; done; }
refresh() { sleep 0.3; pkill -RTMIN+10 waybar; }
case "${1:-status}" in
  toggle) if active; then off; else on; fi; refresh ;;
  on)  on;  refresh ;;
  off) off; refresh ;;
  *)
    if active; then
      printf '{"text":"%s","class":"on","tooltip":"Caffeine: ON — the laptop will stay awake\\nClick to turn off"}\n' "$(printf '\U000F0176')"
    else
      printf '{"text":"%s","class":"off","tooltip":"Caffeine: off\\nClick to keep the laptop awake"}\n' "$(printf '\U000F06CA')"
    fi ;;
esac
