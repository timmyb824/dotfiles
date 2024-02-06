#!/usr/bin/env bash

# Define safe_remove_command function and other necessary utilities
source "$(dirname "$BASH_SOURCE")/../init/init.sh"
# Function to check if Docker is already installed
check_docker_installed() {
  if command_exists docker; then
    echo "Docker is already installed."
    docker --version
    return 0
  else
    return 1
  fi
}

# Function to install Docker
install_docker() {
    # Add Docker's official GPG key:
    sudo apt-get update
    sudo apt-get install ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    # Add the repository to Apt sources:
    echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

  # Install Docker Engine
  sudo apt-get update
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

  # Add the current user to the Docker group to run Docker commands without sudo
  sudo usermod -aG docker "$USER"
  newgrp docker

  # Output the installed Docker version
  docker --version
}

OS=$(get_os)

# Main script execution
if check_docker_installed; then
  echo "Skipping installation as Docker is already installed."
elif [[ "$OS" == "Linux" ]]; then
  echo_with_color "32" "Docker is not installed. Installing Docker..."
  install_docker
  echo_with_color "32" "Installation complete. You may need to log out and back in or restart your system to use Docker as a non-root user."
elif [[ "$OS" == "MacOS" ]]; then
  echo_with_color "31" "Docker is not supported on macOS. Please install Docker Desktop from the Docker website."
else
  exit_with_error "Unsupported operating system: $OS"
fi
