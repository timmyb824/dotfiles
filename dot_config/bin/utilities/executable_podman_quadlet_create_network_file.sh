#!/bin/bash

source common.sh

if [ -z "$1" ]; then
  echo "Usage: $0 <network_name>"
  exit 1
fi

NETWORK_NAME="$1"
SYSTEMD_USER_DIR="$HOME/.config/containers/systemd"

# Function to create systemd unit file for a container
generate_systemd_unit() {
  msg_info "Creating systemd unit file for network: ${NETWORK_NAME}"
  local network_name="$1"

  # Create systemd user directory if it doesn't exist
  mkdir -p "${SYSTEMD_USER_DIR}"
  cd "${SYSTEMD_USER_DIR}" || exit

  # Generate systemd unit files from running containers
  if podlet --file . generate network "${network_name}"; then
    msg_ok "Successfully generated systemd unit file for network: ${network_name}"
  else
    msg_error "Failed to generate systemd unit file for network: ${network_name}"
    exit 1
  fi
}

daemon_reload() {
  msg_info "Reloading systemd daemon"
  if systemctl --user daemon-reload; then
    msg_ok "Successfully reloaded systemd daemon"
  else
    msg_error "Failed to reload systemd daemon"
    exit 1
  fi
}

# Main script execution
generate_systemd_unit "${NETWORK_NAME}"
daemon_reload

