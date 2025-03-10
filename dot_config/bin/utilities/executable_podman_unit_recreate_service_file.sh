#!/bin/bash

source common.sh

if [ $# -ne 2 ]; then
    echo "Usage: $0 [docker|podman] <service_name>"
    exit 1
fi

COMPOSE_TYPE=$1 # 'docker' or 'podman'
SERVICE_NAME=$2
COMPOSE_FILE="${COMPOSE_TYPE}-compose.yaml"

stop_and_disable_service() {
    msg_info "Stopping and disabling the systemd service"
    local service_name="$1"
    systemctl --user stop "container-$service_name.service"
    systemctl --user disable "container-$service_name.service"
}

remove_container() {
    msg_info "Removing the existing containers"
    local project_name="$1"
    podman-compose -p "$project_name" down
}

# Function to create and start new container with updated configuration
# in-pod=0 prevents pod from being created which seems to cause problems using podman-auto-update
recreate_container() {
    msg_info "Recreating the containers with the new configuration"
    local project_name="$1"
    podman-compose -f "$COMPOSE_FILE" --in-pod=0 -p "$project_name" up -d --force-recreate
}

regenerate_systemd_unit_file() {
    msg_info "Regenerating and enabling the systemd unit file"
    local service_name="$1"

    podman_unit_file.sh "$service_name"
    systemctl --user daemon-reload
    systemctl --user enable --now "container-$service_name.service"
}

msg_info "Recreating user service: $SERVICE_NAME"
stop_and_disable_service "$SERVICE_NAME"
remove_container "$SERVICE_NAME"
recreate_container "$SERVICE_NAME"
regenerate_systemd_unit_file "$SERVICE_NAME"

msg_info "Listing systemd containers"
systemctl --user list-units 'container*'
