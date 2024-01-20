#!/usr/bin/env bash

# Define safe_remove_command function and other necessary utilities
source "$(dirname "$BASH_SOURCE")/../utilities/init.sh"

# Function to install rbenv using Homebrew on macOS
install_rbenv_macos() {
  echo_with_color "32" "Installing rbenv using Homebrew..."
  brew install rbenv ruby-build || exit_with_error "Failed to install rbenv and/or ruby-build."
}

# Function to install rbenv using the official installer script on Linux
install_rbenv_linux() {
  # Install dependencies for rbenv and Ruby build
  sudo apt update || exit_with_error "Failed to update apt."
  sudo apt install -y git curl autoconf bison build-essential libssl-dev libyaml-dev \
    libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm6 libgdbm-dev libdb-dev ||
    exit_with_error "Failed to install dependencies for rbenv and Ruby build."
  curl -fsSL https://github.com/rbenv/rbenv-installer/raw/HEAD/bin/rbenv-installer | bash
}

# Function to initialize rbenv within the script
initialize_rbenv() {
  if [[ "$(get_os)" == "MacOS" ]]; then
    eval "$(rbenv init -)"
  elif [[ "$(get_os)" == "Linux" ]]; then
    export PATH="$HOME/.rbenv/bin:$PATH"
    eval "$(rbenv init -)"
  fi
}

# Function to install Ruby and set it as the global version
install_and_set_ruby() {
  rbenv install $RUBY_VERSION || exit_with_error "Failed to install Ruby version $RUBY_VERSION."
  rbenv global $RUBY_VERSION || exit_with_error "Failed to set Ruby version $RUBY_VERSION as global."
  echo "Ruby installation completed. Ruby version set to $RUBY_VERSION."
}

# Main execution
if [[ "$(get_os)" == "MacOS" ]]; then
  # macOS system
  if command_exists rbenv; then
    echo_with_color "32" "rbenv is already installed."
  else
    install_rbenv_macos
  fi
elif [[ "$(get_os)" == "Linux" ]]; then
  # Linux system
  if ! command_exists rbenv; then
    install_rbenv_linux
  fi
else
  echo "Unsupported OS type: $OSTYPE"
  exit 1
fi

# Initialize rbenv for this script session
initialize_rbenv

# Install Ruby and set the global version
install_and_set_ruby