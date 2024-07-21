#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../init/init.sh"

echo_with_color "$CYAN_COLOR" "PLEASE ENABLE QEMU-GUEST-AGENT WITHIN PROXMOX GUI OR AGENT WILL NOT START"

# Update package lists
echo_with_color "$GREEN_COLOR" "Updating package lists..."
sudo apt-get update || exit_with_error "Failed to update package lists"

# Check if the qemu-guest-agent is installed
if ! dpkg -l | grep -qw qemu-guest-agent; then
    echo_with_color "$GREEN_COLOR" "Installing qemu-guest-agent..."
    sudo apt-get install -y qemu-guest-agent || exit_with_error "Failed to install qemu-guest-agent"
fi

# Ensure qemu-guest-agent is enabled and running
if ! systemctl is-enabled --quiet qemu-guest-agent; then
    echo_with_color "$GREEN_COLOR" "Enabling qemu-guest-agent..."
    sudo systemctl enable qemu-guest-agent || exit_with_error "Failed to enable qemu-guest-agent"
    echo_with_color "$GREEN_COLOR" "PLEASE ENABLE QEMU-GUEST-AGENT WITHIN PROXMOX GUI THE STOP AND START THE VM"
    exit 0
else
    echo_with_color "$GREEN_COLOR" "qemu-guest-agent is already enabled"
fi

if ! systemctl is-active --quiet qemu-guest-agent; then
    echo_with_color "$GREEN_COLOR" "Starting qemu-guest-agent..."
    sudo systemctl start qemu-guest-agent || exit_with_error "Failed to start qemu-guest-agent"
    echo_with_color "$GREEN_COLOR" "qemu-guest-agent is installed and running"
else
    echo_with_color "$GREEN_COLOR" "qemu-guest-agent is already running"
fi



