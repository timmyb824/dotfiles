#!/bin/bash

source common.sh

QUADLET_DIR="$HOME/.config/containers/systemd"
GENERATED_DIR="/run/user/$(id -u)/systemd/generator"

usage() {
  echo "Usage: $0 <action> <type> <name>"
  echo ""
  echo "  Actions: create | delete | recreate"
  echo "  Types:   container | network"
  echo ""
  echo "Examples:"
  echo "  $0 create container myapp"
  echo "  $0 create network mynet"
  echo "  $0 delete container myapp"
  echo "  $0 delete network mynet"
  echo "  $0 recreate container myapp"
  exit 1
}

# ---------------------------------------------------------------------------
# Create helpers
# ---------------------------------------------------------------------------

create_container() {
  local name="$1"
  local quadlet_file="${QUADLET_DIR}/container-${name}.container"

  msg_info "Generating quadlet container file for: ${name}"
  mkdir -p "${QUADLET_DIR}"

  rm -f "${quadlet_file}"
  systemctl --user daemon-reload

  if ! podlet --file "${quadlet_file}" generate container "${name}"; then
    msg_error "Failed to generate container file for: ${name}"
    exit 1
  fi
  msg_ok "Generated: ${quadlet_file}"

  # Ensure the unit starts on boot; podlet does not add [Install] by default
  if ! grep -q '^\[Install\]' "${quadlet_file}"; then
    printf '\n[Install]\nWantedBy=default.target\n' >> "${quadlet_file}"
  fi

  systemctl --user daemon-reload

  msg_info "Starting service: container-${name}.service"
  if ! systemctl --user start "container-${name}.service"; then
    msg_error "Failed to start container-${name}.service"
    exit 1
  fi

  if systemctl --user is-active --quiet "container-${name}.service"; then
    msg_ok "Container ${name} is running"
  else
    msg_error "Container ${name} is not running after start"
    exit 1
  fi
}

create_network() {
  local name="$1"

  msg_info "Generating quadlet network file for: ${name}"
  mkdir -p "${QUADLET_DIR}"
  cd "${QUADLET_DIR}" || exit 1

  if ! podlet --file . generate network "${name}"; then
    msg_error "Failed to generate network file for: ${name}"
    exit 1
  fi
  msg_ok "Generated: ${QUADLET_DIR}/${name}.network"

  systemctl --user daemon-reload
  msg_ok "Daemon reloaded — network ${name} will be available as ${name}-network.service"
}

# ---------------------------------------------------------------------------
# Delete helpers
# ---------------------------------------------------------------------------

delete_container() {
  local name="$1"
  local unit_file="${QUADLET_DIR}/container-${name}.container"

  msg_info "Stopping service: container-${name}.service"
  systemctl --user stop "container-${name}.service" 2>/dev/null \
    || msg_warn "Service container-${name}.service was not running"

  msg_info "Removing quadlet file: ${unit_file}"
  rm -f "${unit_file}" || msg_warn "File ${unit_file} not found"

  systemctl --user daemon-reload

  msg_info "Stopping and removing container: ${name}"
  podman stop "${name}" 2>/dev/null || msg_warn "Container ${name} was not running"
  podman rm "${name}" 2>/dev/null || msg_warn "Container ${name} did not exist"

  msg_ok "Removed container quadlet: ${name}"
}

delete_network() {
  local name="$1"
  local unit_file="${QUADLET_DIR}/${name}.network"
  local generated_file="${GENERATED_DIR}/${name}-network.service"

  msg_info "Stopping network service: ${name}-network.service"
  systemctl --user stop "${name}-network.service" 2>/dev/null \
    || msg_warn "Network service ${name}-network.service was not running"

  msg_info "Removing quadlet file: ${unit_file}"
  rm -f "${unit_file}" || msg_warn "File ${unit_file} not found"

  msg_info "Removing generated file: ${generated_file}"
  rm -f "${generated_file}" || msg_warn "Generated file ${generated_file} not found"

  systemctl --user daemon-reload
  msg_ok "Removed network quadlet: ${name}"
}

# ---------------------------------------------------------------------------
# Dispatch
# ---------------------------------------------------------------------------

ACTION="${1}"
TYPE="${2}"
NAME="${3}"

[ -z "${ACTION}" ] || [ -z "${TYPE}" ] || [ -z "${NAME}" ] && usage

case "${TYPE}" in
  container | network) ;;
  *) msg_error "Unknown type '${TYPE}'. Must be 'container' or 'network'."; usage ;;
esac

case "${ACTION}" in
  create)
    case "${TYPE}" in
      container) create_container "${NAME}" ;;
      network)   create_network "${NAME}" ;;
    esac
    ;;
  delete)
    case "${TYPE}" in
      container) delete_container "${NAME}" ;;
      network)   delete_network "${NAME}" ;;
    esac
    ;;
  recreate)
    case "${TYPE}" in
      container)
        delete_container "${NAME}"
        create_container "${NAME}"
        ;;
      network)
        delete_network "${NAME}"
        create_network "${NAME}"
        ;;
    esac
    ;;
  *)
    msg_error "Unknown action '${ACTION}'. Must be 'create', 'delete', or 'recreate'."
    usage
    ;;
esac
