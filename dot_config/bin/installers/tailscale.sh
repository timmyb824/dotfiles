#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../init/init.sh"

# Function to install tailscale on macOS
install_tailscale_macos() {
    if mas list | grep -q "Tailscale"; then
        echo_with_color "$BLUE_COLOR" "Tailscale is already installed."
    else
        echo_with_color "$GREEN_COLOR" "Installing Tailscale..."
        mas install 1475387142
        if mas list | grep -q "Tailscale"; then
            echo_with_color "$GREEN_COLOR" "Tailscale has been successfully installed. Please start Tailscale manually from your Applications folder."
        else
            echo_with_color "$RED_COLOR" "Failed to install Tailscale."
        fi
    fi
}

add_brew_to_path

# Main execution
if ! command_exists brew; then
    # Provide instructions to install Homebrew if not found
    echo_with_color "$YELLOW_COLOR" "Homebrew is not installed. Please install Homebrew for ARM macOS first."
    exit_with_error "Homebrew installation required"
elif ! command_exists mas; then
    # mas-cli is necessary to install Tailscale from the Mac App Store
    echo_with_color "$RED_COLOR" "mas-cli is not installed. Please install mas-cli to proceed."
    exit_with_error "mas-cli installation required"
else
    install_tailscale_macos
fi