#!/bin/bash

source common.sh

# Check if a service name was provided
if [ -z "$1" ]; then
    echo "Usage: $0 <service-name>"
    exit 1
fi

# Service name is the first argument
SERVICE_NAME="$1"
UNIT_FILE="$SERVICE_NAME.service"
CONTAINER_FILE="$HOME/.config/containers/systemd/$SERVICE_NAME.container"

msg_info "Stopping service $SERVICE_NAME."
if systemctl --user stop "$UNIT_FILE"; then
    msg_ok "Service $SERVICE_NAME has been stopped."
else
    msg_warn "Service $SERVICE_NAME is not running."
fi

# Disable the user service
# if systemctl --user disable "$UNIT_FILE"; then
#     echo "Service $SERVICE_NAME has been disabled."
# else
#     echo "Service $SERVICE_NAME is not enabled."
# fi

msg_info "Removing service and container files for $SERVICE_NAME."
rm -f "$CONTAINER_FILE" || echo "Container file $CONTAINER_FILE does not exist."

if systemctl --user daemon-reload; then
    msg_ok "Successfully reloaded systemd daemon."
else
    msg_error "Failed to reload systemd daemon."
    exit 1
fi

# if systemctl --user reset-failed "$UNIT_FILE" 2>/dev/null; then
#     echo "Failed state for $SERVICE_NAME has been reset."
# fi

msg_info "Stopping and removing container for $SERVICE_NAME."
podman stop "$SERVICE_NAME" || echo "Container $SERVICE_NAME is not running."
podman rm "$SERVICE_NAME" || echo "Container $SERVICE_NAME does not exist."

msg_info "Service and container for $SERVICE_NAME have been removed."

