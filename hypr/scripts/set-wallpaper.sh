#!/usr/bin/env bash
# usage: set-wallpaper.sh /path/to/image  — applies wallpaper and regenerates colors
set -euo pipefail
img="$(realpath "$1")"
cache="$HOME/.cache"
ln -sf "$img" "$cache/current-wallpaper"
echo "$img" > "$cache/last-wallpaper"

# keep hyprpaper.conf in sync so a restart keeps the wallpaper
sed -i "s|^\(\s*path = \).*|\1$img|" "$HOME/.config/hypr/hyprpaper.conf"
if pgrep -x hyprpaper >/dev/null; then
    hyprctl hyprpaper wallpaper ",$img,cover" >/dev/null 2>&1 || { pkill -x hyprpaper; setsid hyprpaper >/dev/null 2>&1 & }
else
    setsid hyprpaper >/dev/null 2>&1 &
fi

# regenerate palette (matugen templates -> hypr, waybar, rofi, swaync, kitty, gtk…)
if command -v matugen >/dev/null; then
    matugen image "$img" --mode dark --prefer saturation >/dev/null 2>&1 || notify-send -a Wallpaper "matugen failed" "colors not updated"
fi
hyprctl reload >/dev/null 2>&1 || true
pkill -SIGUSR2 waybar 2>/dev/null || true          # waybar reloads style
swaync-client -rs >/dev/null 2>&1 || true          # swaync reload css
pkill -USR1 -x kitty 2>/dev/null || true           # kitty reload config
