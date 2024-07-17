#!/bin/bash

# Check if both arguments are provided
if [ $# -ne 2 ]; then
  echo "Usage: $0 [docker|podman] <service_name>"
  exit 1
fi

COMPOSE_TYPE=$1  # 'docker' or 'podman'
SERVICE_NAME=$2
COMPOSE_FILE="${COMPOSE_TYPE}-compose.yaml"

# Function to stop and disable systemd service
stop_and_disable_service() {
    local service_name="$1"
    systemctl --user stop "container-$service_name.service"
    systemctl --user disable "container-$service_name.service"
}

# Function to remove existing container
remove_container() {
    local project_name="$1"
    podman-compose -p "$project_name" down
}

# Function to create and start new container with updated configuration
recreate_container() {
    local project_name="$1"
    podman-compose -f "$COMPOSE_FILE" -p "$project_name" up -d --force-recreate
}

# Function to regenerate systemd unit file
regenerate_systemd_unit_file() {
    local service_name="$1"

    # Assuming the presence of a utility script to regenerate unit file here
    podman_unit_file.sh "$service_name"
    systemctl --user daemon-reload
    systemctl --user enable --now "container-$service_name.service"
}

echo_color() {
    local color="$1"
    local message="$2"
    echo -e "\e[${color}m${message}\e[0m"
}

echo_color 32 "Updating service $SERVICE_NAME with $COMPOSE_TYPE"

echo_color 32 "Stopping and disabling the systemd service"
# Stop and disable the systemd service
stop_and_disable_service "$SERVICE_NAME"

echo_color 32 "Removing the existing containers"
# Remove the existing containers
remove_container "$SERVICE_NAME"

echo_color 32 "Recreating the containers with the new configuration"
# Recreate the containers with the new configuration
recreate_container "$SERVICE_NAME"

echo_color 32 "Regenerating and enabling the systemd unit file"
# Regenerate and enable the systemd unit file
regenerate_systemd_unit_file "$SERVICE_NAME"

echo_color 32 "Service $SERVICE_NAME updated successfully"
# List the systemd units to verify
systemctl --user list-units 'container*'
