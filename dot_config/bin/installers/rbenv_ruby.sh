#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../init/init.sh"

# Function to install rbenv using Homebrew on macOS
install_rbenv_macos() {
  echo_with_color "$GREEN_COLOR" "Installing rbenv using Homebrew on macOS..."
  if ! command_exists brew; then
    exit_with_error "Homebrew could not be found. Please install Homebrew to continue."
  fi

  brew update
  brew install rbenv ruby-build

  if ! command_exists rbenv; then
    exit_with_error "rbenv installation failed."
  fi
}

# Function to initialize rbenv within the script
initialize_rbenv() {
  echo_with_color "$GREEN_COLOR" "Initializing rbenv for the current macOS session..."
  eval "$(rbenv init -)"
}

# Function to install Ruby and set it as the global version
install_and_set_ruby() {
  if [[ -z "$RUBY_VERSION" ]]; then
    exit_with_error "RUBY_VERSION is not set. Cannot proceed with Ruby installation."
  fi
  echo_with_color "$GREEN_COLOR" "Installing Ruby version $RUBY_VERSION..."
  rbenv install "$RUBY_VERSION" || exit_with_error "Failed to install Ruby version $RUBY_VERSION."
  echo_with_color "$GREEN_COLOR" "Setting Ruby version $RUBY_VERSION as global..."
  rbenv global "$RUBY_VERSION" || exit_with_error "Failed to set Ruby version $RUBY_VERSION as global."
  echo_with_color "$GREEN_COLOR" "Ruby installation completed. Ruby version set to $RUBY_VERSION."
}

# Call the function to add Homebrew to the path
add_brew_to_path

# Main execution
if ! command_exists rbenv; then
  echo_with_color "$GREEN_COLOR" "rbenv could not be found. Starting installation process..."
  install_rbenv_macos
else
  echo_with_color "$GREEN_COLOR" "rbenv is already installed."
fi

initialize_rbenv
install_and_set_ruby