#!/usr/bin/env bash
# Enables real hibernation using swap partition /dev/nvme0n1p2 (13G) + suspend-then-hibernate.
# Run:  bash ~/.config/hypr/setup/2-setup-hibernation.sh
set -euo pipefail
SWAP_DEV=/dev/nvme0n1p2
UUID="$(lsblk -no UUID "$SWAP_DEV")"
echo "Swap UUID: $UUID"

# 1) initramfs resume hook (before filesystems)
if ! grep -qE '^HOOKS=.*\bresume\b' /etc/mkinitcpio.conf; then
  sudo cp /etc/mkinitcpio.conf /etc/mkinitcpio.conf.bak
  sudo sed -i -E '/^HOOKS=/ s/\bfilesystems\b/resume filesystems/' /etc/mkinitcpio.conf
fi
grep ^HOOKS /etc/mkinitcpio.conf

# 2) kernel parameter in Limine
CONF="$(sudo find /boot /efi -maxdepth 4 -name 'limine.conf' 2>/dev/null | head -1)"
[ -n "$CONF" ] || { echo "limine.conf not found — add resume=UUID=$UUID to your kernel cmdline manually"; exit 1; }
sudo cp "$CONF" "$CONF.bak"
if ! sudo grep -q "resume=UUID=$UUID" "$CONF"; then
  sudo sed -i -E "s|^(\s*)(kernel_)?cmdline:\s*(.*)|\1\2cmdline: \3 resume=UUID=$UUID|I" "$CONF"
fi
sudo grep -i cmdline "$CONF"

# 3) sleep + lid behaviour
sudo mkdir -p /etc/systemd/sleep.conf.d /etc/systemd/logind.conf.d
sudo tee /etc/systemd/sleep.conf.d/hibernate.conf >/dev/null <<EOT
[Sleep]
AllowSuspend=yes
AllowHibernation=yes
AllowSuspendThenHibernate=yes
HibernateMode=platform shutdown
HibernateDelaySec=45min
EOT
sudo tee /etc/systemd/logind.conf.d/power.conf >/dev/null <<EOT
[Login]
HandleLidSwitch=suspend-then-hibernate
HandleLidSwitchExternalPower=suspend
HandleLidSwitchDocked=ignore
HandlePowerKey=ignore
HandlePowerKeyLongPress=poweroff
EOT

# 4) rebuild initramfs
sudo mkinitcpio -P
echo "Done. Reboot, then test:  systemctl hibernate"
