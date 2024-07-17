#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../init/init.sh"

# Define variables
VERSION="1.8.1"
OS=${OS:-"linux"}
ARCH="${ARCH:-"amd64"}"
DOWNLOAD_URL="https://github.com/prometheus/node_exporter/releases/download/v${VERSION}/node_exporter-${VERSION}.${OS}-${ARCH}.tar.gz"
INSTALL_DIR="/usr/local/bin"
SERVICE_FILE="/etc/systemd/system/node_exporter.service"

# Function to create systemd service file
create_systemd_service_file() {
    echo_with_color "$GREEN_COLOR" "Creating Node Exporter systemd service file..."

    sudo tee $SERVICE_FILE > /dev/null <<EOL
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
ExecStart=${INSTALL_DIR}/node_exporter
User=node_exporter
Restart=on-failure

[Install]
WantedBy=default.target
EOL
}

start_node_exporter_service() {
    echo_with_color "$GREEN_COLOR" "Starting node_exporter service..."
    sudo systemctl daemon-reload || exit_with_error "Failed to reload systemd daemon."
    sudo systemctl enable --now node_exporter || exit_with_error "Failed to enable and start podman service."
    sudo systemctl status --no-pager node_exporter || exit_with_error "Failed to check podman service status."
    echo_with_color "$GREEN_COLOR" "node_exporter service started successfully."
}

# Main script
main() {
    # Download and extract Node Exporter
    echo_with_color "$GREEN_COLOR" "Downloading Node Exporter..."
    wget $DOWNLOAD_URL -O /tmp/node_exporter.tar.gz
    echo_with_color "$GREEN_COLOR" "Extracting Node Exporter..."
    tar -C /tmp -xvf /tmp/node_exporter.tar.gz

    # Move the binary to the installation directory
    echo_with_color "$GREEN_COLOR" "Installing Node Exporter..."
    sudo mv /tmp/node_exporter-${VERSION}.${OS}-${ARCH}/node_exporter $INSTALL_DIR

    # Create a dedicated user for Node Exporter
    echo_with_color "$GREEN_COLOR" "Creating dedicated user for Node Exporter..."
    sudo useradd --no-create-home --shell /bin/false node_exporter

    # Set ownership and permissions
    echo_with_color "$GREEN_COLOR" "Setting ownership and permissions..."
    sudo chown node_exporter:node_exporter ${INSTALL_DIR}/node_exporter

    # Create systemd service file
    create_systemd_service_file

    # Start and enable the Node Exporter service
    start_node_exporter_service

    # Cleanup
    echo_with_color "$GREEN_COLOR" "Cleaning up..."
    rm -rf /tmp/node_exporter*
}

# Execute the main function
main