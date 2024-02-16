#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../init/init.sh"

# Function to install rbenv using Homebrew on macOS
install_rbenv_macos() {
  echo_with_color "32" "Installing rbenv using Homebrew on macOS..."
  if command_exists brew; then
    echo_with_color "32" "Homebrew is already installed."
  else
    if [[ -x "/opt/homebrew/bin/brew" ]]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    else
      echo_with_color "33" "Homebrew is not installed. Please run homebrew.sh first."
      exit_with_error "Homebrew installation required"
    fi
  fi
  brew update
  brew install rbenv ruby-build
}

# Function to initialize rbenv within the script
initialize_rbenv() {
  echo_with_color "32" "Initializing rbenv for the current macOS session..."
  eval "$(rbenv init -)"
}

# Function to install Ruby and set it as the global version
install_and_set_ruby() {
  echo_with_color "32" "Installing Ruby version $RUBY_VERSION..."
  rbenv install $RUBY_VERSION || exit_with_error "Failed to install Ruby version $RUBY_VERSION."
  echo_with_color "32" "Setting Ruby version $RUBY_VERSION as global..."
  rbenv global $RUBY_VERSION || exit_with_error "Failed to set Ruby version $RUBY_VERSION as global."
  echo "Ruby installation completed. Ruby version set to $RUBY_VERSION."
}

# Main execution
if command_exists rbenv; then
  echo_with_color "32" "rbenv is already installed."
else
  install_rbenv_macos || exit_with_error "Failed to install rbenv."
fi

initialize_rbenv
install_and_set_ruby