#!/bin/bash

source common.sh

log_file="$HOME/DEV/logs/podman-auto-update.log"

logger() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" | tee -a "$log_file"
}

if [ ! -d "$(dirname "$log_file")" ]; then
    msg_info "Creating log directory: $(dirname "$log_file")"
    if mkdir -p "$(dirname "$log_file")"; then
        msg_ok "Log directory created successfully."
    else
        handle_error "Failed to create log directory."
    fi
fi

if ! command_exists podman; then
    handle_error "podman is not installed."
fi

# Check for updates
updates=$(podman auto-update --dry-run --format "{{.Image}} {{.Updated}}")

pending_updates=$(echo "$updates" | grep "pending")

if [[ -z "$pending_updates" ]]; then
    logger "No updates available."
else
    logger "Updates available for the following images:"
    echo "$pending_updates" | tee -a "$log_file"

    # Perform the update
    if podman auto-update; then
        msg_ok "Podman auto-update completed successfully."
    else
        msg_error "Podman auto-update failed."
    fi
fi
