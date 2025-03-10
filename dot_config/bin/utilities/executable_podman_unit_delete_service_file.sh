#!/bin/bash

source common.sh

if [ -z "$1" ]; then
    echo "Usage: $0 <service-name>"
    exit 1
fi

SERVICE_NAME="$1"
UNIT_FILE="container-$SERVICE_NAME.service"

msg_info "Stopping user service $UNIT_FILE"
systemctl --user stop "$UNIT_FILE" || msg_warn "User service $UNIT_FILE is not running."

msg_info "Disabling user service $UNIT_FILE"
systemctl --user disable "$UNIT_FILE" || msg_warn "User service $UNIT_FILE is not enabled."

msg_info "Removing user service file $HOME/.config/systemd/user/$UNIT_FILE"
rm -f "$HOME/.config/systemd/user/$UNIT_FILE" || msg_warn "User service file $HOME/.config/systemd/user/$UNIT_FILE does not exist."

msg_info "Reloading user daemon"
systemctl --user daemon-reload

msg_info "Resetting failed state of $UNIT_FILE"
systemctl --user reset-failed "$UNIT_FILE"

msg_info "Stopping and removing container $SERVICE_NAME"
podman stop "$SERVICE_NAME" || msg_warn "Container $SERVICE_NAME is not running."
podman rm "$SERVICE_NAME" || msg_warn "Container $SERVICE_NAME does not exist."

msg_ok "Service and container for $SERVICE_NAME have been removed."

msg_info "Remaining user services:"
systemctl --user list-units 'container*'
