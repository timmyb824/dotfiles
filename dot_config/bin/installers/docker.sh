#!/usr/bin/env bash

# Source necessary utilities
source "$(dirname "$BASH_SOURCE")/../init/init.sh"

# Function to check if Docker is installed
check_docker_installed() {
  if command_exists docker; then
    echo_with_color "$GREEN_COLOR" "Docker is already installed."
    docker --version
    return 0
  else
    return 1
  fi
}

# Function to install Docker
install_docker() {
  # Ensure sudo is available
  if ! command_exists sudo; then
    echo_with_color "$RED_COLOR" "sudo command is required but not found. Please install sudo first."
    return 1
  fi

  # Update package index and install prerequisites
  sudo apt-get update
  sudo apt-get install -y ca-certificates curl

  # Add Docker's official GPG key
  sudo mkdir -p /etc/apt/keyrings
  if ! sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc; then
    echo_with_color "$RED_COLOR" "Failed to download Docker's GPG key."
    return 1
  fi
  sudo chmod a+r /etc/apt/keyrings/docker.asc

  # Add the Docker repository
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release; echo "$VERSION_CODENAME") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

  # Install Docker Engine
  sudo apt-get update
  if ! sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin; then
    echo_with_color "$RED_COLOR" "Failed to install Docker packages."
    return 1
  fi

  # Add the current user to the Docker group
  if ! sudo usermod -aG docker "$USER"; then
    echo_with_color "$RED_COLOR" "Failed to add $USER to the Docker group. You may need to logout and login again."
    return 1
  fi

  # Output the installed Docker version
  docker --version

  echo_with_color "$GREEN_COLOR" "Docker installed successfully. Please log out and back in or restart your system to use Docker as a non-root user."
}

# Main script execution
if check_docker_installed; then
  echo_with_color "$GREEN_COLOR" "Skipping installation as Docker is already installed."
else
  echo_with_color "$YELLOW_COLOR" "Docker is not installed. Installing Docker..."
  install_docker
fi