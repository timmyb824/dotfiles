#!/bin/bash

source common.sh

if [ -z "$1" ]; then
	echo "Usage: $0 <container_name>"
	exit 1
fi

CONTAINER_NAME="$1"
SYSTEMD_USER_DIR="$HOME/.config/systemd/user"

generate_systemd_unit() {
	local container_name="$1"
	local restart_policy="$2"

	mkdir -p "${SYSTEMD_USER_DIR}"
	cd "${SYSTEMD_USER_DIR}" || exit

	if [ -z "${restart_policy}" ]; then
		podman generate systemd --new --name --files "${container_name}"
	else
		podman generate systemd --restart-policy="${restart_policy}" --new --name --files "${container_name}"
	fi
}

enable_systemd_service() {
	local container_name="$1"

	systemctl --user enable --now "container-$container_name"
}

list_systemd_containers() {
	systemctl --user --no-pager --plain --full --no-legend \
		list-units 'container*' | awk '{print $1}'
}

msg_info "Creating systemd unit file for container: ${CONTAINER_NAME}"
generate_systemd_unit "${CONTAINER_NAME}" "always"

msg_info "Enabling systemd service for container: ${CONTAINER_NAME}"
enable_systemd_service "${CONTAINER_NAME}"

msg_info "Listing systemd containers"
list_systemd_containers
