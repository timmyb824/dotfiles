#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../init/init.sh"

OS=$(get_os)

# function to install rustup with error handling
install_rustup() {
    # Install rustup
    if ! command_exists rustup; then
        echo_with_color "$YELLOW_COLOR" "Installing rustup..."
        if curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y; then
            echo_with_color "$GREEN_COLOR" "rustup installed successfully."
        else
            exit_with_error "Failed to install rustup, please check the installation script."
        fi
    else
        echo_with_color "$GREEN_COLOR" "rustup is already installed."
    fi
}

install_rust_dependencies() {
    # Install Rust dependencies
    echo_with_color "$YELLOW_COLOR" "Installing Rust dependencies..."
    if sudo apt-get install -y build-essential; then
        echo_with_color "$GREEN_COLOR" "Rust dependencies installed successfully."
    else
        exit_with_error "Failed to install Rust dependencies, please check the installation script."
    fi
}

if [ "$OS" == "Linux" ]; then
    install_rust_dependencies
fi

install_rustup
