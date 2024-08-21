#!/bin/bash

source ../../init/init.sh

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

enable_timer_and_service() {
    msg_info "Enabling podman-auto-update.timer..."
    sudo systemctl enable podman-auto-update.timer
    if [ $? -ne 0 ]; then
        msg_error "Failed to enable podman-auto-update.timer"
        exit 1
    fi

    msg_info "Enabling podman-auto-update.service..."
    sudo systemctl enable podman-auto-update.service
    if [ $? -ne 0 ]; then
        msg_error "Failed to enable podman-auto-update.service"
        exit 1
    fi

    msg_ok "podman-auto-update.timer and service have been enabled."
}

check_status() {
    status=$(systemctl status podman-auto-update.timer | grep "Active:" | awk '{print $2}')
    if [ "$status" = "active" ]; then
        msg_info "podman-auto-update.timer is active"
        disable_timer_and_service
    else
        msg_info "podman-auto-update timer is not active"
        enable_timer_and_service
    fi
}

check_status
