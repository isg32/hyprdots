#!/usr/bin/env bash
last="$(cat "$HOME/.cache/last-wallpaper" 2>/dev/null || true)"
[ -f "$last" ] || last="$HOME/Pictures/Wallpapers/wall0.png"
exec "$HOME/.config/hypr/scripts/set-wallpaper.sh" "$last"
