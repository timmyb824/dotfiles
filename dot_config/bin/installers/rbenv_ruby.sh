#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../init/init.sh"

OS=$(get_os)

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

install_rbenv_linux() {
  echo_with_color "$GREEN" "Installing rbenv and dependencies on Linux..."
  sudo apt update || exit_with_error "Failed to update apt."
  sudo apt install -y git curl autoconf bison build-essential libssl-dev libyaml-dev \
    libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm6 libgdbm-dev libdb-dev ||
    exit_with_error "Failed to install dependencies for rbenv and Ruby build."
  curl -fsSL https://github.com/rbenv/rbenv-installer/raw/HEAD/bin/rbenv-installer | bash
}

# Function to initialize rbenv within the script
initialize_rbenv() {
  echo_with_color "$GREEN_COLOR" "Initializing rbenv for the current session..."
  if [[ "$OS" == "MacOS" ]]; then
    eval "$(rbenv init -)"
  elif [[ "$OS" == "Linux" ]]; then
    export PATH="$HOME/.rbenv/bin:$PATH"
    eval "$(rbenv init -)"
  else
    exit_with_error "Unsupported operating system: $OS"
  fi
}

# Function to install Ruby and set it as the global version
install_and_set_ruby() {
  if [[ -z "$RUBY_VERSION" ]]; then
    exit_with_error "RUBY_VERSION is not set. Cannot proceed with Ruby installation."
  fi

  if rbenv versions | grep -q "$RUBY_VERSION"; then
    echo_with_color "$GREEN" "Ruby version $RUBY_VERSION is already installed."
  else
    echo_with_color "$GREEN" "Installing Ruby version $RUBY_VERSION..."
    rbenv install "$RUBY_VERSION" || exit_with_error "Failed to install Ruby version $RUBY_VERSION."
  fi

  echo_with_color "$GREEN" "Setting Ruby version $RUBY_VERSION as global..."
  rbenv global "$RUBY_VERSION" || exit_with_error "Failed to set Ruby version $RUBY_VERSION as global."
}

if ! command_exists rbenv; then
  if [[ "$OS" == "MacOS" ]]; then
    add_brew_to_path
    install_rbenv_macos
  elif [[ "$OS" == "Linux" ]]; then
    install_rbenv_linux
  else
    exit_with_error "Unsupported operating system: $OS"
  fi
else
  echo_with_color "$GREEN_COLOR" "rbenv is already installed."
fi

initialize_rbenv
install_and_set_ruby