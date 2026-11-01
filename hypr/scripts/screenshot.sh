#!/usr/bin/env bash
# screenshot.sh [region|screen]
#  region: drag to select an area; a plain click/tap captures the whole screen
#  screen: whole focused monitor immediately
# Saves to ~/Pictures/Screenshots, copies to clipboard, small notification.
dir="$HOME/Pictures/Screenshots"; mkdir -p "$dir"
file="$dir/Screenshot_$(date +%Y-%m-%d_%H-%M-%S).png"
mode="${1:-region}"
pgrep -x slurp >/dev/null && exit 0

if [ "$mode" = region ]; then
    # offer every monitor as a predefined box: a plain click/tap picks the monitor under the cursor
    boxes=$(hyprctl monitors -j | jq -r '.[] | "\(.x),\(.y) \((.width/.scale)|floor)x\((.height/.scale)|floor)"')
    geo=$(printf '%s\n' "$boxes" | slurp -d -b '#00000066' -c '#a8e063' -w 2 -s '#a8e06322') || exit 0
    w=${geo#*,*,}; w=${w%%x*}; h=${geo##*x}
    if [ "${w:-0}" -lt 6 ] || [ "${h:-0}" -lt 6 ]; then mode=screen; fi
fi

if [ "$mode" = screen ]; then
    mon=$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .name')
    grim -o "$mon" "$file" || exit 1
else
    grim -g "$geo" "$file" || exit 1
fi

wl-copy --type image/png < "$file"
notify-send -a Screenshot -i "$file" -t 3000 "Screenshot copied" "Saved to Pictures/Screenshots"
