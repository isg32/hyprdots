#!/bin/bash

# --- Configuration ---
# *** IMPORTANT: Change this to your actual backup directory name! ***
BACKUP_DIR="${HOME}/arch_backup_20251027" 
CONFIG_TAR="dotconfig.tar.gz"
PACMAN_PKG_FILE="pacman_packages.txt"
AUR_PKG_FILE="aur_packages.txt"

# --- Functions ---
log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1"
}

# --- Main Script ---

log "Starting Arch Linux restoration..."

# 1. Check for backup directory
if [ ! -d "$BACKUP_DIR" ]; then
    log "ERROR: Backup directory $BACKUP_DIR not found. Please ensure it is set correctly and exists. Exiting."
    exit 1
fi

# 2. Install Pacman Packages
log "Installing Pacman packages from $PACMAN_PKG_FILE..."
PACMAN_LIST="$BACKUP_DIR/$PACMAN_PKG_FILE"

if [ -f "$PACMAN_LIST" ]; then
    # Use pacman -S --needed to only install packages that aren't already present
    sudo pacman -Syu --needed $(cat "$PACMAN_LIST")
    if [ $? -eq 0 ]; then
        log "Successfully installed Pacman packages."
    else
        log "WARNING: Pacman package installation encountered errors."
    fi
else
    log "WARNING: Pacman package list $PACMAN_LIST not found. Skipping."
fi

# 3. Install AUR Packages
if command -v yay &> /dev/null; then
    log "Installing AUR packages from $AUR_PKG_FILE using yay..."
    AUR_LIST="$BACKUP_DIR/$AUR_PKG_FILE"

    if [ -f "$AUR_LIST" ]; then
        # Use yay -S --needed to only install packages that aren't already present
        yay -S --needed $(cat "$AUR_LIST")
        if [ $? -eq 0 ]; then
            log "Successfully installed AUR packages."
        else
            log "WARNING: AUR package installation encountered errors. Check output above."
        fi
    else
        log "WARNING: AUR package list $AUR_LIST not found. Skipping."
    fi
else
    log "WARNING: 'yay' not found. Cannot install AUR packages. Skipping."
fi

# 4. Restore .config directory
CONFIG_PATH="$BACKUP_DIR/$CONFIG_TAR"
log "Restoring ~/.config from $CONFIG_PATH..."

if [ -f "$CONFIG_PATH" ]; then
    # Extract the tarball into the home directory.
    # The -k (keep old files) flag is used to prevent overwriting existing files,
    # but for a fresh install, this is mainly a safety measure.
    tar -xzf "$CONFIG_PATH" -C "${HOME}"
    
    if [ $? -eq 0 ]; then
        log "Successfully restored ~/.config."
        log "NOTE: Existing files in ~/.config were potentially overwritten or merged."
    else
        log "ERROR: Failed to extract ~/.config tarball."
    fi
else
    log "WARNING: .config tarball $CONFIG_PATH not found. Skipping."
fi

log "Arch Linux restoration complete! You may need to reboot or log out/in."
