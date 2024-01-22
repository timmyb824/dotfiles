#!/usr/bin/env bash

# Define safe_remove_command function and other necessary utilities
source "$(dirname "$BASH_SOURCE")/../utilities/init.sh"

# Function to install rbenv using Homebrew on macOS
install_rbenv_macos() {
  echo_with_color "32" "Installing rbenv using Homebrew..."
  # Check for Homebrew in the common installation locations
  if command_exists brew; then
    echo_with_color "32" "Homebrew is already installed."
  else
    # Attempt to initialize Homebrew if it's installed but not in the PATH
    if [[ -x "/opt/homebrew/bin/brew" ]]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    else
      # Homebrew is not installed, provide instructions to install it
      echo_with_color "33" "Homebrew is not installed. Please run homebrew.sh first."
      exit_with_error "Homebrew installation required"
    fi
  fi
  brew update
  brew install rbenv ruby-build
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
    echo_with_color "32" "Initializing rbenv for the current MacOS session..."
    eval "$(rbenv init -)"
  elif [[ "$(get_os)" == "Linux" ]]; then
    echo_with_color "32" "Initializing rbenv for the current Linux session..."
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
    install_rbenv_macos || exit_with_error "Failed to install rbenv."
    echo_with_color "32" "rbenv has been successfully installed."
    echo_with_color "32" "Please restart your terminal to initialize rbenv"
    echo_with_color "32" "Install ruby by running `rbenv install $RUBY_VERSION`"
  fi
elif [[ "$(get_os)" == "Linux" ]]; then
  # Linux system
  if command_exists rbenv; then
    echo_with_color "32" "rbenv is already installed."
  else
    install_rbenv_linux
    initialize_rbenv
    install_and_set_ruby
  fi
else
  exit_with_error "Unsupported OS type: $OSTYPE"
fi

# TODO: MacOS installation fails at the last step but it works if I run the commands manually in the terminal,
# therefore moving these steps to run for Linux only and adding instructions for MacOS users to run them manually
# initialize_rbenv
# install_and_set_ruby
