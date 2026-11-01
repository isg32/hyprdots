#!/usr/bin/env bash
# nightlight.sh [status|next|up|down|off|set N]  — 4 warmth levels via hyprsunset (0 = off)
temps=(6500 5000 4200 3500 2800)           # index = level; 1 = gentle ... 4 = warmest
names=(Off Gentle Warm Warmer Warmest)
state="$HOME/.cache/nightlight-level"
running() { pgrep -x hyprsunset >/dev/null; }
level() { running && cat "$state" 2>/dev/null || echo 0; }

apply() {   # apply level $1
  local l=$1; [ "$l" -lt 0 ] && l=0; [ "$l" -gt 4 ] && l=4
  if [ "$l" -eq 0 ]; then
    pkill -x hyprsunset; echo 0 > "$state"
  else
    if running; then hyprctl hyprsunset temperature "${temps[$l]}" >/dev/null 2>&1
    else setsid hyprsunset -t "${temps[$l]}" >/dev/null 2>&1 & fi
    echo "$l" > "$state"
  fi
  sleep 0.3; pkill -RTMIN+8 waybar
}

cur=$(level)
case "${1:-status}" in
  next|toggle) apply $(( (cur + 1) % 5 )) ;;
  up)          apply $(( cur + 1 )) ;;
  down)        apply $(( cur - 1 )) ;;
  off)         apply 0 ;;
  set)         apply "${2:-0}" ;;
  *)
    if [ "$cur" -eq 0 ]; then
      printf '{"text":"%s","class":"off","tooltip":"Night light: off\\nClick: level 1  ·  scroll: adjust"}\n' "$(printf '\U000F0599')"
    else
      printf '{"text":"%s %s","class":"on level-%s","tooltip":"Night light: level %s/4 — %s (%sK)\\nClick: next  ·  right-click: off  ·  scroll: adjust"}\n' \
        "$(printf '\U000F0594')" "$cur" "$cur" "$cur" "${names[$cur]}" "${temps[$cur]}"
    fi ;;
esac
