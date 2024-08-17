#!/bin/bash

source common.sh

# Check if container name is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <container_name>"
  exit 1
fi

CONTAINER_NAME="$1"
SYSTEMD_USER_DIR="$HOME/.config/containers/systemd"

# Function to create systemd unit file for a container
generate_systemd_unit() {
  msg_info "Creating systemd unit file for container: ${CONTAINER_NAME}"
  local container_name="$1"

  # Create systemd user directory if it doesn't exist
  mkdir -p "${SYSTEMD_USER_DIR}"
  cd "${SYSTEMD_USER_DIR}" || exit

  # Generate systemd unit files from running containers
  if podlet --file . generate container "${container_name}"; then
    msg_ok "Successfully generated systemd unit file for container: ${container_name}"
  else
    msg_error "Failed to generate systemd unit file for container: ${container_name}"
    exit 1
  fi
}

start_systemd_service() {
  msg_info "Starting systemd service for container: ${CONTAINER_NAME}"
  local container_name="$1"
  systemctl --user daemon-reload
  if systemctl --user start "${container_name}.service"; then
    msg_ok "Successfully started systemd service for container: ${container_name}"
  else
    msg_error "Failed to start systemd service for container: ${container_name}"
    exit 1
  fi
}

check_service_status() {
  msg_info "Checking status of systemd service for container: ${CONTAINER_NAME}"
  local container_name="$1"
  if systemctl --user is-active "${container_name}.service"; then
    msg_ok "Container: ${container_name} is running"
  else
    msg_error "Container: ${container_name} is not running"
    exit 1
  fi
}

# Main script execution
generate_systemd_unit "${CONTAINER_NAME}"
start_systemd_service "${CONTAINER_NAME}"
check_service_status "${CONTAINER_NAME}"
