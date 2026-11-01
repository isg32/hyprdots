#!/usr/bin/env bash
# Run:  bash ~/.config/hypr/setup/1-install-packages.sh   (asks for sudo password)
set -euo pipefail
sudo pacman -S --needed --noconfirm \
  waybar rofi rofi-emoji rofi-calc swaync libnotify \
  hyprsunset hyprpm cmake meson cpio pkgconf git base-devel \
  matugen nwg-look qt5ct qt6ct kvantum papirus-icon-theme \
  brightnessctl playerctl cliphist pavucontrol blueman nm-connection-editor \
  gvfs gvfs-mtp udiskie swappy imagemagick jq socat fastfetch btop yazi thunar \
  ttf-jetbrains-mono-nerd ttf-firacode-nerd ttf-nerd-fonts-symbols ttf-nerd-fonts-symbols-mono \
  otf-font-awesome inter-font ttf-roboto ttf-opensans ttf-ibm-plex ttf-fira-sans ttf-cascadia-code \
  noto-fonts noto-fonts-cjk noto-fonts-emoji ttf-liberation ttf-dejavu ttf-hack adobe-source-sans-fonts

# Replace old notifier/launcher
sudo pacman -Rns --noconfirm dunst wofi || true
echo "Done. Next: hyprpm update && hyprpm add https://github.com/hyprwm/hyprland-plugins && hyprpm enable hyprexpo"
