#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../init/init.sh"

# Function to uninstall Docker
uninstall_docker() {
  # Check if Docker is installed
  if command_exists docker; then
    echo_with_color "33" "Docker is installed, proceeding with uninstallation."

    # Stop and remove all docker containers
    docker stop $(docker ps -aq) 2>/dev/null
    docker rm $(docker ps -aq) 2>/dev/null

    # Remove all docker images
    docker rmi $(docker images -q) 2>/dev/null

    # Uninstall Docker packages
    sudo apt-get purge -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    # Remove Docker's official GPG key and repository source
    sudo rm -f /etc/apt/keyrings/docker.asc
    sudo rm -f /etc/apt/sources.list.d/docker.list

    # Remove Docker group
    sudo groupdel docker

    # Clean up remaining Docker directories
    sudo rm -rf /var/lib/docker
    sudo rm -rf /var/lib/containerd

    # Refresh package index
    sudo apt-get update

    # Remove unused packages and their associated configuration files
    sudo apt-get autoremove -y --purge

    echo_with_color "32" "Docker has been successfully uninstalled."
  else
    echo_with_color "31" "Docker is not installed, nothing to uninstall."
  fi
}

# Main script execution
echo_with_color "33" "Starting Docker uninstallation process..."
uninstall_docker