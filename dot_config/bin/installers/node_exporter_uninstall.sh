#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../init/init.sh"

# Define variables
INSTALL_DIR="/usr/local/bin"
SERVICE_FILE="/etc/systemd/system/node_exporter.service"
USER="node_exporter"

# Function to stop and disable the Node Exporter service
stop_node_exporter_service() {
    echo_with_color "$GREEN_COLOR" "Stopping Node Exporter service..."
    if systemctl is-active --quiet node_exporter; then
        sudo systemctl stop node_exporter || echo_with_color "$RED_COLOR" "Failed to stop Node Exporter service."
    fi

    echo_with_color "$GREEN_COLOR" "Disabling Node Exporter service..."
    if systemctl is-enabled --quiet node_exporter; then
        sudo systemctl disable node_exporter || echo_with_color "$RED_COLOR" "Failed to disable Node Exporter service."
    fi

    echo_with_color "$GREEN_COLOR" "Removing Node Exporter service file..."
    if [ -f "$SERVICE_FILE" ]; then
        sudo rm -f "$SERVICE_FILE" || echo_with_color "$RED_COLOR" "Failed to remove Node Exporter service file."
        sudo systemctl daemon-reload || echo_with_color "$RED_COLOR" "Failed to reload systemd daemon."
    fi
}

# Function to remove Node Exporter binary
remove_node_exporter_binary() {
    echo_with_color "$GREEN_COLOR" "Removing Node Exporter binary..."
    if [ -f "${INSTALL_DIR}/node_exporter" ]; then
        sudo rm -f "${INSTALL_DIR}/node_exporter" || echo_with_color "$RED_COLOR" "Failed to remove Node Exporter binary."
    fi
}

# Function to remove the dedicated user
remove_node_exporter_user() {
    echo_with_color "$GREEN_COLOR" "Removing Node Exporter user..."
    if id -u "$USER" >/dev/null 2>&1; then
        sudo userdel -r "$USER" || echo_with_color "$RED_COLOR" "Failed to remove Node Exporter user."
    fi
}

# Main script
main() {
    stop_node_exporter_service
    remove_node_exporter_binary
    remove_node_exporter_user
}

# Execute the main function
main