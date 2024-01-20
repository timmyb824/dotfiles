#!/usr/bin/env bash

# Define safe_remove_command function and other necessary utilities
source "$(dirname "$BASH_SOURCE")/../utilities/init.sh"

# Function to install rbenv using the official installer script
install_rbenv() {
  # Install dependencies for rbenv and Ruby build
  sudo apt update || exit_with_error "Failed to update apt."
  sudo apt install -y git curl autoconf bison build-essential libssl-dev libyaml-dev \
    libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm6 libgdbm-dev libdb-dev ||
    exit_with_error "Failed to install dependencies for rbenv and Ruby build."
  curl -fsSL https://github.com/rbenv/rbenv-installer/raw/HEAD/bin/rbenv-installer | bash
}

# Function to initialize rbenv within the script
initialize_rbenv() {
  export PATH="$HOME/.rbenv/bin:$PATH"
  eval "$(rbenv init -)"
}

# Function to install Ruby and set it as the global version
install_and_set_ruby() {
  rbenv install $RUBY_VERSION
  rbenv global $RUBY_VERSION
  echo "Ruby installation completed. Ruby version set to $RUBY_VERSION."
}

# Main execution
if [[ "$(get_os)" == "MacOS" ]]; then
  # macOS system
  if command_exists rbenv; then
    echo "rbenv is already installed."
  else
    echo "Please install rbenv using Homebrew:"
    echo "  brew install rbenv"
    exit 0
  fi
elif [[ "$(get_os)" == "Linux" ]]; then
  # Linux system
  if ! command_exists rbenv; then
    install_rbenv
  fi
else
  echo "Unsupported OS type: $OSTYPE"
  exit 1
fi

# Initialize rbenv for this script session
initialize_rbenv || exit_with_error "Failed to initialize rbenv."

# Install Ruby and set the global version
install_and_set_ruby || exit_with_error "Failed to install Ruby."
