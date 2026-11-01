#!/usr/bin/env bash
# Plays a sound for each new notification (called by swaync on receive).
[ "$(swaync-client -D 2>/dev/null)" = true ] && exit 0          # silent in Do Not Disturb
lock=/tmp/swaync-sound.lock                                      # avoid a burst of overlapping sounds
now=$(date +%s%N); last=$(cat "$lock" 2>/dev/null || echo 0)
[ $(( (now - last) / 1000000 )) -lt 600 ] && exit 0
echo "$now" > "$lock"
dir=/usr/share/sounds/freedesktop/stereo
case "$SWAYNC_URGENCY" in
  Critical) f=dialog-warning ;;
  *)        f=message-new-instant ;;
esac
exec paplay --volume=42000 "$dir/$f.oga"
