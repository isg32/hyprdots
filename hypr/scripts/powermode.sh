#!/usr/bin/env bash
# Performance modes: performance | balanced | saver   (uses power-profiles-daemon + Hyprland effects)
state="$HOME/.cache/powermode"
apply() {
  case "$1" in
    performance)
      powerprofilesctl set performance
      hyprctl eval 'hl.config({decoration={blur={enabled=true,passes=3},shadow={enabled=true}},animations={enabled=true}})' ;;
    balanced)
      powerprofilesctl set balanced
      hyprctl eval 'hl.config({decoration={blur={enabled=true,passes=2},shadow={enabled=true}},animations={enabled=true}})' ;;
    saver)
      powerprofilesctl set power-saver
      hyprctl eval 'hl.config({decoration={blur={enabled=false},shadow={enabled=false}},animations={enabled=false}})'
      brightnessctl -q set 40% ;;
    *) exit 1 ;;
  esac
  echo "$1" > "$state"
  notify-send -a "Power" -i battery "Power mode" "$1"
}
case "${1:-menu}" in
  restore) m="$(cat "$state" 2>/dev/null || echo balanced)"; apply "$m" ;;
  menu)
    pkill -x rofi && exit 0
    c="$(printf '󰓅  Performance\n󰾅  Balanced\n󰌪  Battery saver' | rofi -dmenu -i -p "Power mode" -theme "$HOME/.config/rofi/powermenu.rasi")"
    case "$c" in *Performance) apply performance;; *Balanced) apply balanced;; *saver) apply saver;; esac ;;
  cycle) case "$(cat "$state" 2>/dev/null)" in performance) apply balanced;; balanced) apply saver;; *) apply performance;; esac ;;
  *) apply "$1" ;;
esac
