#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../init/init.sh"

# SERVICE_FILE="/etc/systemd/system/podman_exporter.service"
REPO_LOCATION="$HOME/DEV/podman_exporter"
USER=$CURRENT_USER
SCRIPT_LOCATION="$HOME/DEV/scripts/podman_exporter"
SCRIPT_NAME="podman_exporter.sh"
LOG_NAME="podman_exporter.log"

install_dependencies() {
    echo_with_color "$GREEN_COLOR" "Installing dependencies..."
    sudo apt install -y btrfs-progs libdevmapper-dev libgpgme-dev libassuan-dev || exit_with_error "Failed to install dependencies."
}

clone_podman_exporter() {
    echo_with_color "$GREEN_COLOR" "Creating directory for podman_exporter..."
    mkdir -p "$REPO_LOCATION" || exit_with_error "Failed to create directory: $REPO_LOCATION"
    echo_with_color "$GREEN_COLOR" "Cloning podman_exporter..."
    git clone https://github.com/containers/prometheus-podman-exporter.git "$REPO_LOCATION" || exit_with_error "Failed to clone podman_exporter."

    echo_with_color "$GREEN_COLOR" "Building podman_exporter; this may take a while..."
    cd "$REPO_LOCATION" || exit_with_error "Failed to change directory to $REPO_LOCATION"
    make binary || exit_with_error "Failed to build podman_exporter."
}

create_nohup_script() {
    echo_with_color "$GREEN_COLOR" "Creating directory for scripts..."
    mkdir -p "$SCRIPT_LOCATION" || exit_with_error "Failed to create directory: $SCRIPT_LOCATION"
    echo_with_color "$GREEN_COLOR" "Creating log file..."
    touch "$SCRIPT_LOCATION/$LOG_NAME" || exit_with_error "Failed to create log file."
    echo_with_color "$GREEN_COLOR" "Creating nohup script..."
    tee "$SCRIPT_LOCATION/$SCRIPT_NAME" >/dev/null <<EOL
#!/bin/bash

# Define variables
TOOL_PATH="$REPO_LOCATION/bin/prometheus-podman-exporter"
LOG_FILE="$SCRIPT_LOCATION/podman_exporter.log"
ARGS="-a"

# Run the tool with nohup
nohup \$TOOL_PATH \$ARGS > \$LOG_FILE 2>&1 &

# Output the PID of the background process
echo "Podman Exporter is running with PID \$!"
EOL
}

run_nohup_script() {
    echo_with_color "$GREEN_COLOR" "Running nohup script..."
    chmod +x "$SCRIPT_LOCATION/$SCRIPT_NAME" || exit_with_error "Failed to make script executable."
    "$SCRIPT_LOCATION/$SCRIPT_NAME" || exit_with_error "Failed to run nohup script."
}

# create_systemd_service_file() {
#     echo_with_color "$GREEN_COLOR" "Creating Podman Exporter systemd service file..."

#     sudo tee $SERVICE_FILE > /dev/null <<EOL
# [Unit]
# Description=Podman Exporter
# After=network-online.target

# [Service]
# Type=simple
# User=$USER
# ExecStart=$REPO_LOCATION/bin/prometheus-podman-exporter -a
# Restart=on-failure
# RestartSec=5

# [Install]
# WantedBy=multi-user.target

# EOL
# }

# start_podman_exporter_service() {
#     echo_with_color "$GREEN_COLOR" "Starting podman service..."
#     sudo systemctl daemon-reload || exit_with_error "Failed to reload systemd daemon."
#     sudo systemctl enable --now podman_exporter || exit_with_error "Failed to enable and start podman service."
#     sudo systemctl status --no-pager podman_exporter || exit_with_error "Failed to check podman service status."
#     echo_with_color "$GREEN_COLOR" "podman_exporter service started successfully."
# }

# Main script
main() {
    if ! command_exists "podman" || ! command_exists "git" || ! command_exists "make" || ! command_exists "nohup"; then
        exit_with_error "One or more dependencies are not installed. Please install Podman, Git, Make, and ensure that nohup is available."
    fi

    install_dependencies
    clone_podman_exporter
    create_nohup_script
    run_nohup_script
    # create_systemd_service_file
    # start_podman_exporter_service

    echo_with_color "$GREEN_COLOR" "Podman Exporter installation completed successfully."
}

main
