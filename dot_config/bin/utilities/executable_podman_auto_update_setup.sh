#!/bin/bash

# Function to check if the timer is active and enabled
check_status() {
    systemctl is-active --quiet podman-auto-update.timer
    local active=$?
    systemctl is-enabled --quiet podman-auto-update.timer
    local enabled=$?
    return $((active + enabled))
}

# Function to enable and configure the timer
enable_and_configure_timer() {
    echo "Enabling podman-auto-update.timer..."
    sudo systemctl enable podman-auto-update.timer
    if [ $? -ne 0 ]; then
        echo "Failed to enable podman-auto-update.timer"
        exit 1
    fi

    echo "Setting custom schedule for podman-auto-update.timer..."
    # Create a directory for the override if it doesn't exist
    sudo mkdir -p /etc/systemd/system/podman-auto-update.timer.d/
    # Create the override configuration file
    echo -e "# Editing /etc/systemd/system/podman-auto-update.timer.d/override.conf\n# Anything between here and the comment below will become the new contents of the file\n[Timer]\nOnCalendar=Fri *-*-* 18:00" | sudo tee /etc/systemd/system/podman-auto-update.timer.d/override.conf > /dev/null

    # Reload the daemon to apply changes
    sudo systemctl daemon-reload
    if [ $? -ne 0 ]; then
        echo "Failed to reload systemd daemon after modifying timer"
        exit 1
    fi

    # Restart the timer to apply changes
    sudo systemctl restart podman-auto-update.timer
    if [ $? -ne 0 ]; then
        echo "Failed to restart podman-auto-update.timer"
        exit 1
    fi
}

# Function to perform a dry-run update check
perform_dry_run() {
    echo "Checking for updates (dry-run)..."
    podman auto-update --dry-run
    if [ $? -ne 0 ]; then
        echo "Failed to perform dry-run update check"
        exit 1
    fi
}

# Main script execution
# Check if the timer is active and enabled
check_status
status=$?

if [ $status -ne 0 ]; then
    echo "podman-auto-update.timer is not active or enabled. Configuring now..."
    enable_and_configure_timer
else
    echo "podman-auto-update.timer is active and enabled."
fi

# Perform a dry-run update check
perform_dry_run

echo "Script completed successfully."
echo "Please run 'podman login docker.io' to authenticate with Docker Hub if you haven't already."