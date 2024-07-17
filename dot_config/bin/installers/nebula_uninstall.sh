#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../init/init.sh"


stop_and_disable_nebula_service() {
  echo_with_color "$GREEN_COLOR" "Stopping and disabling Nebula service..."
  if systemctl is-active --quiet nebula; then
    sudo systemctl stop nebula || exit_with_error "Failed to stop nebula service."
  fi
  if systemctl is-enabled --quiet nebula; then
    sudo systemctl disable nebula || exit_with_error "Failed to disable nebula service."
  fi
}

remove_nebula_systemd_unit() {
  echo_with_color "$GREEN_COLOR" "Removing Nebula systemd unit file..."
  if [ -f /etc/systemd/system/nebula.service ]; then
    sudo rm /etc/systemd/system/nebula.service || exit_with_error "Failed to remove nebula systemd unit file."
    sudo systemctl daemon-reload || exit_with_error "Failed to reload systemd daemon."
  fi
}

remove_nebula_directory() {
  echo_with_color "$GREEN_COLOR" "Removing Nebula directory..."
  if [ -d /etc/nebula ]; then
    sudo rm -rf /etc/nebula || exit_with_error "Failed to remove /etc/nebula directory."
  fi
}

remove_nebula_user() {
  echo_with_color "$GREEN_COLOR" "Removing Nebula user..."
  if id "nebula" &>/dev/null; then
    sudo userdel -r nebula || exit_with_error "Failed to remove nebula user."
  fi
  if [ -f /etc/sudoers.d/nebula ]; then
    sudo rm /etc/sudoers.d/nebula || exit_with_error "Failed to remove nebula sudoers file."
  fi
}

remove_nebula_binaries(){
  echo_with_color "$GREEN_COLOR" "Removing Nebula binaries..."
  if [ -f /usr/local/bin/nebula ]; then
    sudo rm /usr/local/bin/nebula || exit_with_error "Failed to remove nebula binary."
  fi
  if [ -f /usr/local/bin/nebula-cert ]; then
    sudo rm /usr/local/bin/nebula-cert || exit_with_error "Failed to remove nebula-cert binary."
  fi
}

remove_ca_key_and_cert() {
  echo_with_color "$GREEN_COLOR" "Removing CA key and certificate..."
  if [ -f "$HOME/ca.key" ]; then
    rm "$HOME/ca.key" || exit_with_error "Failed to remove CA key."
  fi
  if [ -f "$HOME/ca.crt" ]; then
    rm "$HOME/ca.crt" || exit_with_error "Failed to remove CA certificate."
  fi
}

main() {
  echo "Nebula Overlay Network Teardown Script"
  echo "====================================="

  stop_and_disable_nebula_service
  remove_nebula_systemd_unit
  remove_nebula_directory
  remove_nebula_user
  remove_nebula_binaries
  remove_ca_key_and_cert

  echo_with_color "$GREEN_COLOR" "Nebula has been successfully removed."
}

main "$@"