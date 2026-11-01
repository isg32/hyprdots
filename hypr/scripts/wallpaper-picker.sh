#!/usr/bin/env bash
# Smooth carousel wallpaper picker (GTK4 layer-shell). Toggles if already open.
for p in $(pgrep -x python3); do
    if tr '\0' ' ' < "/proc/$p/cmdline" | grep -q 'wallpaper-picker'; then kill "$p"; exit 0; fi
done
dir="$HOME/Pictures/Wallpapers"; thumbs="$HOME/.cache/wallthumbs"; mkdir -p "$thumbs"
while IFS= read -r -d '' f; do
    name="$(basename "$f")"; t="$thumbs/${name%.*}.png"
    [ -f "$t" ] && [ "$t" -nt "$f" ] || magick "$f" -resize 560x316^ -gravity center -extent 560x316 "$t" 2>/dev/null
done < <(find "$dir" -maxdepth 1 -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \) -print0)
# gtk4-layer-shell must be loaded before libwayland-client
exec env LD_PRELOAD=/usr/lib/libgtk4-layer-shell.so python3 "$HOME/.config/hypr/scripts/wallpaper-picker.py"
