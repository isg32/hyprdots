#!/usr/bin/env bash
# One-time setup (needs sudo): lets your user flip Lenovo "conservation mode" (limits charging to ~60%) without a password.
# Run:  bash ~/.config/hypr/setup/3-battery-conservation.sh
set -euo pipefail
user="${SUDO_USER:-$USER}"
sudo install -m 0755 /dev/stdin /usr/local/bin/battery-conservation <<'HELPER'
#!/usr/bin/env bash
# battery-conservation on|off|status  — root helper for Lenovo ideapad conservation mode
f=$(ls /sys/bus/platform/drivers/ideapad_acpi/VPC*/conservation_mode 2>/dev/null | head -1)
[ -n "$f" ] || { echo "conservation_mode not supported on this machine" >&2; exit 2; }
case "${1:-}" in
  on)     echo 1 > "$f" ;;
  off)    echo 0 > "$f" ;;
  status) cat "$f" ;;
  *)      echo "usage: battery-conservation on|off|status" >&2; exit 1 ;;
esac
HELPER
echo "$user ALL=(root) NOPASSWD: /usr/local/bin/battery-conservation" | sudo tee /etc/sudoers.d/battery-conservation >/dev/null
sudo chmod 0440 /etc/sudoers.d/battery-conservation
sudo visudo -c -f /etc/sudoers.d/battery-conservation
echo "Done. Test:  sudo -n /usr/local/bin/battery-conservation status"
