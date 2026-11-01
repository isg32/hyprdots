#!/usr/bin/env bash
# media.sh title|play  — waybar JSON for the active MPRIS player; prints nothing (module hides) when idle
st=$(playerctl status 2>/dev/null)
case "$st" in Playing|Paused) ;; *) exit 0 ;; esac
case "${1:-title}" in
  play)
    if [ "$st" = Playing ]; then icon=$(printf '\U000F03E4'); else icon=$(printf '\U000F040A'); fi
    jq -nc --arg t "$icon" --arg c "$(echo "$st" | tr A-Z a-z)" '{text:$t,class:$c,tooltip:""}' ;;
  title)
    artist=$(playerctl metadata artist 2>/dev/null); title=$(playerctl metadata title 2>/dev/null); player=$(playerctl -l 2>/dev/null | head -1)
    [ -z "$title" ] && title="Unknown track"
    label="$title"; [ -n "$artist" ] && label="$artist  ·  $title"
    short="$label"; [ ${#short} -gt 38 ] && short="${short:0:37}…"
    jq -nc --arg t "$short" --arg c "$(echo "$st" | tr A-Z a-z)" --arg tip "$label"$'\n'"$player · $st"$'\n'"Click: play/pause · scroll: volume · right-click: next" '{text:$t,class:$c,tooltip:$tip}' ;;
esac
