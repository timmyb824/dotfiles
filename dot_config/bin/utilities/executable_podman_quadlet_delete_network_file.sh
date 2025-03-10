#!/bin/bash

source common.sh

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

  msg_info "Stopping network ${network_name}."
  if systemctl --user stop "${unit_file}"; then
    msg_ok "Network ${network_name} has been stopped."
  else
    msg_warn "Network ${network_name} is not running."
  fi

  msg_info "Removing network files for ${network_name}."
  rm -f "${unit_file}" || msg_warn "Network file ${unit_file} does not exist."

  msg_info "Removing generated network files for ${network_name}."
  rm -f "${generated_file}" || msg_warn "Generated network file ${generated_file} does not exist."
}

daemon_reload() {
  systemctl --user daemon-reload
}

delete_network_files "${1}"
daemon_reload
