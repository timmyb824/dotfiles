#!/usr/bin/env bash

# macOS Tailscale Installation Script

source "$(dirname "$BASH_SOURCE")/../init/init.sh"

# Function to install tailscale on macOS
install_tailscale_macos() {
    if mas list | grep -q "Tailscale"; then
        echo_with_color "34" "Tailscale is already installed."
    else
        if ask_yes_or_no "Tailscale is not installed. Would you like to install Tailscale?"; then
            echo_with_color "32" "Installing Tailscale..."
            mas install 1475387142
            if mas list | grep -q "Tailscale"; then
                echo_with_color "32" "Tailscale has been successfully installed. Please start Tailscale manually from your Applications folder."
            else
                echo_with_color "31" "Failed to install Tailscale."
            fi
        else
            echo_with_color "34" "Skipping Tailscale installation."
        fi
    fi
}

# Main execution
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

if command_exists mas; then
    install_tailscale_macos
else
    exit_with_error "mas-cli is not installed. Please install mas-cli to proceed."
fi