#!/bin/bash

source common.sh

log_file="/var/log/podman-auto-update.log"

logger() {
    echo -e "\033[1;35m$(date +'%Y-%m-%d %H:%M:%S') - $1\033[0m" | tee -a "$log_file"
    echo -e "---------------------------------------------" | tee -a "$log_file"
}

# Check if podman is installed
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