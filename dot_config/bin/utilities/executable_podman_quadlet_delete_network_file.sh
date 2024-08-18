#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: $0 <network_name>"
  exit 1
fi

UID=$(id -u)
SYSTEMD_USER_DIR="$HOME/.config/containers/systemd"
SYSTEMD_USER_GENERATED_DIR="/run/user/${UID}/systemd/generator"

delete_network_files() {
  local network_name="$1"
  local unit_file="${SYSTEMD_USER_DIR}/${network_name}.network"
  local generated_file="${SYSTEMD_USER_GENERATED_DIR}/${network_name}-network.service"

echo "Stopping network ${network_name}."
  if systemctl --user stop "${unit_file}"; then
    echo "Network ${network_name} has been stopped."
  else
    echo "Network ${network_name} is not running."
  fi

  echo "Removing network files for ${network_name}."
  rm -f "${unit_file}" || echo "Network file ${unit_file} does not exist."

echo "Removing generated network files for ${network_name}."
  rm -f "${generated_file}" || echo "Generated network file ${generated_file} does not exist."
}

daemon_reload() {
  systemctl --user daemon-reload
}

# Main script execution
delete_network_files "${NETWORK_NAME}"
daemon_reload

