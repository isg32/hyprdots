#!/bin/bash

# --- Configuration ---
BACKUP_DIR="${HOME}/arch_backup_$(date +%Y%m%d)"
CONFIG_TAR="dotconfig.tar.gz"
PACMAN_PKG_FILE="pacman_packages.txt"
AUR_PKG_FILE="aur_packages.txt"

# --- Functions ---
log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1"
}

# --- Main Script ---

log "Starting Arch Linux backup..."

# 1. Create the backup directory
if [ ! -d "$BACKUP_DIR" ]; then
    mkdir -p "$BACKUP_DIR"
    if [ $? -ne 0 ]; then
        log "ERROR: Could not create backup directory $BACKUP_DIR. Exiting."
        exit 1
    fi
    log "Created backup directory: $BACKUP_DIR"
else
    log "Backup directory $BACKUP_DIR already exists."
fi

# 2. Backup .config directory
log "Backing up ~/.config directory..."
if [ -d "${HOME}/.config" ]; then
    # Create a compressed tarball of ~/.config
    tar -czf "$BACKUP_DIR/$CONFIG_TAR" -C "${HOME}" .config
    if [ $? -eq 0 ]; then
        log "Successfully backed up ~/.config to $BACKUP_DIR/$CONFIG_TAR"
    else
        log "ERROR: Failed to create tarball for ~/.config."
    fi
else
    log "WARNING: ~/.config directory not found. Skipping."
fi

# 3. List explicitly installed Pacman packages
log "Listing explicitly installed Pacman packages..."
# The -Qe flag lists all explicitly installed packages
pacman -Qqe > "$BACKUP_DIR/$PACMAN_PKG_FILE"
if [ $? -eq 0 ]; then
    log "Successfully listed Pacman packages to $BACKUP_DIR/$PACMAN_PKG_FILE"
else
    log "ERROR: Failed to list Pacman packages."
fi

# 4. List AUR packages installed via yay
if command -v yay &> /dev/null; then
    log "Listing AUR packages installed via yay..."
    # The -Qe flag lists all explicitly installed packages, then filter out
    # packages known to be from the official Arch repos (which pacman -Qqe already captured)
    # This is a common method, but may not be 100% accurate if non-AUR packages were manually built.
    yay -Qme > "$BACKUP_DIR/$AUR_PKG_FILE"
    if [ $? -eq 0 ]; then
        log "Successfully listed AUR packages to $BACKUP_DIR/$AUR_PKG_FILE"
    else
        log "ERROR: Failed to list AUR packages using yay."
    fi
else
    log "WARNING: 'yay' not found. Skipping AUR package listing."
fi

log "Arch Linux backup complete! Files are located in $BACKUP_DIR"
