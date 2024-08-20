#!/bin/bash

source common.sh

# Function to disable the timer and service
disable_timer_and_service() {
    msg_info "Disabling podman-auto-update.timer..."
    sudo systemctl disable --now podman-auto-update.timer
    if [ $? -ne 0 ]; then
        msg_error "Failed to disable podman-auto-update.timer"
        exit 1
    fi

    msg_info "Disabling podman-auto-update.service..."
    sudo systemctl disable --now podman-auto-update.service
    if [ $? -ne 0 ]; then
        msg_error "Failed to disable podman-auto-update.service"
        exit 1
    fi

    msg_ok "podman-auto-update.timer and service have been disabled."
}

# Main script execution
disable_timer_and_service

msg_ok "Script to disable auto-update completed successfully."