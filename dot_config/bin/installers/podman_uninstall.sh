#!/usr/bin/env bash

# Source necessary utilities
source "$(dirname "$BASH_SOURCE")/../init/init.sh"

# Function to check if Podman is installed
check_podman_installed() {
    if command_exists podman; then
        return 0
    else
        echo_with_color "32" "Podman is not installed."
        return 1
    fi
}

stop_podman_user_services() {
    # Stop the Podman services
    if ! systemctl --user stop podman.socket podman.service; then
        echo_with_color "31" "Failed to stop Podman services."
        return 1
    fi
    echo_with_color "32" "Podman services stopped successfully."
}

stop_root_podman_services() {
    # Stop the Podman services
    if ! sudo systemctl stop podman.socket podman.service; then
        echo_with_color "31" "Failed to stop Podman services."
        return 1
    fi
    echo_with_color "32" "Podman services stopped successfully."
}

# Function to uninstall Podman
uninstall_podman() {
    # Ensure sudo is available
    if ! command_exists sudo; then
        echo_with_color "31" "sudo command is required but not found. Please install sudo first."
        return 1
    fi

    # Remove Podman and its dependencies
    if ! sudo apt remove -y podman; then
        echo_with_color "31" "Failed to remove Podman."
        return 1
    fi

    # Remove the repository for Podman
    if ! sudo rm /etc/apt/sources.list.d/devel:kubic:libcontainers:unstable.list; then
        echo_with_color "31" "Failed to remove Podman repository."
        return 1
    fi

    # Remove the GPG key for the repository
    if ! sudo rm /etc/apt/trusted.gpg.d/devel_kubic_libcontainers_unstable.gpg; then
        echo_with_color "31" "Failed to remove the GPG key for the Podman repository."
        return 1
    fi

    # Update the package database
    if ! sudo apt update; then
        echo_with_color "31" "Failed to update the package database."
        return 1
    fi

    echo_with_color "32" "Podman uninstalled successfully."

    # Remove podman-compose
    if command_exists pip; then
        if ! pip uninstall -y podman-compose; then
            echo_with_color "31" "Failed to uninstall podman-compose."
            return 1
        fi
        echo_with_color "32" "podman-compose uninstalled successfully."
    fi

    # Remove Podman configurations
    local config_dir="$HOME/.config/containers"
    if [[ -d "$config_dir" ]]; then
        if ! rm -rf "$config_dir"; then
            echo_with_color "31" "Failed to remove Podnfiguration directory."
            return 1
        fi
        echo_with_color "32" "Podman configuration directory removed successfully."
    fi

    # remove systemd user unit files (if uninstalling/reinstalling leaving these may help restart the containers)
#    local systemd_dir="$HOME/.config/systemd"
#    if [[ -d "$systemd_dir" ]]; then
#      if ! rm -rf "$systemd_dir"; then
#          echo_with_color "31" "Failed to remove systemd user unit files."
#          return 1
#      fi
#      echo_with_color "32" "Systemd user unit files removed successfully."
#    fi

    # Disable lingering for the user
    if ! sudo loginctl disable-linger "$USER"; then
        echo_with_color "31" "Failed to disable lingering for user $USER."
        return 1
    fi
    echo_with_color "32" "Lingering disabled for user $USER."

    # Remove sysctl configuration for privileged ports
    local sysctl_conf="/etc/sysctl.d/podman-privileged-ports.conf"
    if [[ -f "$sysctl_conf" ]]; then
        if ! sudo rm "$sysctl_conf"; then
            echo_with_color "31" "Failed to remove sysctl configuration for privileged ports."
            return 1
        fi
        echo_with_color "32" "Sysctl configuration for privileged ports removed successfully."
    fi

    # Symlink removal
    if [[ -L /var/run/docker.sock ]]; then
        if ! sudo rm /var/run/docker.sock; then
            echo_with_color "31" "Failed to remove Docker symlink."
            return 1
        fi
        echo_with_color "32" "Docker symlink removed successfully."
    fi

    echo_with_color "32" "Podman and its configurations were completely uninstalled."
}

# Main script execution
if check_podman_installed; then
    echo_with_color "33" "Uninstalling Podman..."
    stop_podman_user_services
    stop_root_podman_services
    uninstall_podman
else
    echo_with_color "32" "Podman is not installed. Nothing to do."
fi
