#!/bin/bash

source common.sh

# Check if container name is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <container_name>"
  exit 1
fi

CONTAINER_NAME="$1"
SYSTEMD_USER_DIR="$HOME/.config/systemd/user"

# Function to create systemd unit file for a container
generate_systemd_unit() {
  local container_name="$1"
  local restart_policy="$2"

  # Create systemd user directory if it doesn't exist
  mkdir -p "${SYSTEMD_USER_DIR}"
  cd "${SYSTEMD_USER_DIR}" || exit

  # Generate systemd unit files from running containers
  if [ -z "${restart_policy}" ]; then
    podman generate systemd --new --name --files "${container_name}"
  else
    podman generate systemd --restart-policy="${restart_policy}" --new --name --files "${container_name}"
  fi
}

# Function to enable the systemd unit file
enable_systemd_service() {
  local container_name="$1"

  # Enable start on reboot
  systemctl --user enable --now "container-$container_name"
}

# Function to list running systemd containers
list_systemd_containers() {
  systemctl --user list-units 'container*'
}

msg_info "Creating systemd unit file for container: ${CONTAINER_NAME}"
generate_systemd_unit "${CONTAINER_NAME}" "always"

msg_info "Enabling systemd service for container: ${CONTAINER_NAME}"
enable_systemd_service "${CONTAINER_NAME}"

msg_info "Listing systemd containers"
list_systemd_containers
