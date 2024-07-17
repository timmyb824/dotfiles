#!/bin/bash

# Check if a service name was provided
if [ -z "$1" ]; then
    echo "Usage: $0 <service-name>"
    exit 1
fi

# Service name is the first argument
SERVICE_NAME="$1"
UNIT_FILE="container-$SERVICE_NAME.service"

# Stop the user service
systemctl --user stop "$UNIT_FILE"

# Disable the user service
systemctl --user disable "$UNIT_FILE"

# Remove the user service file
rm -f "$HOME/.config/systemd/user/$UNIT_FILE"

# Reload the daemon in case the file removal needs to be recognized
systemctl --user daemon-reload
systemctl --user reset-failed "$UNIT_FILE"

# Stop and remove the container
podman stop "$SERVICE_NAME" || echo "Container $SERVICE_NAME is not running."
podman rm "$SERVICE_NAME" || echo "Container $SERVICE_NAME does not exist."

echo "Service and container for $SERVICE_NAME have been removed."

echo "Remaining user services:"
systemctl --user list-units 'container*'
