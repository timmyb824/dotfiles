#!/bin/bash

###################################
# Check OS and Install Tailscale  #
###################################

source "$(dirname "$BASH_SOURCE")/init.sh"

# Function to install tailscale on Linux
install_tailscale_linux() {
    echo_with_color "34" "Tailscale is not installed. Would you like to install Tailscale? (y/n)"
    read -r install_confirm
    if [[ "$install_confirm" =~ ^[Yy]$ ]]; then
        echo_with_color "35" "Please enter your Tailscale authorization key:"
        read -r TAILSCALE_AUTH_KEY

        echo_with_color "32" "Installing Tailscale..."

        # Add the Tailscale repository signing key and repository
        curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/jammy.noarmor.gpg | sudo tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null
        curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/jammy.tailscale-keyring.list | sudo tee /etc/apt/sources.list.d/tailscale.list

        # Update the package list and install Tailscale
        sudo apt-get update -y
        sudo apt-get install tailscale -y

        # Start Tailscale and authenticate
        sudo tailscale up --authkey="$TAILSCALE_AUTH_KEY" --operator="$USER"
    else
        echo_with_color "34" "Skipping Tailscale installation."
    fi
}

# Function to install tailscale on macOS
install_tailscale_macos() {
    if mas list | grep -q "Tailscale"; then
        echo_with_color "34" "Tailscale is already installed."
    else
        echo_with_color "35" "Tailscale is not installed. Would you like to install Tailscale? (y/n)"
        read -r install_confirm
        if [[ "$install_confirm" =~ ^[Yy]$ ]]; then
            echo_with_color "35" "Please enter your Tailscale authorization key:"
            read -r TAILSCALE_AUTH_KEY

            echo_with_color "32" "Installing Tailscale..."
            mas install 1475387142
            # Check if Tailscale is successfully installed after the attempt
            if mas list | grep -q "Tailscale"; then
                echo_with_color "32" "Tailscale has been successfully installed."
                # Start Tailscale and authenticate
                sudo tailscale up --authkey="$TAILSCALE_AUTH_KEY" --operator="$USER"
            else
                echo_with_color "31" "Failed to install Tailscale."
            fi
        else
            echo_with_color "31" "Skipping Tailscale installation."
        fi
    fi
}

# Detect the operating system
OS=$(get_os)

if [[ "$OS" == "MacOS" ]]; then
    # macOS specific checks
    if ! command -v mas &>/dev/null; then
        echo "mas-cli is not installed. Please install mas-cli to proceed."
        exit 1
    fi
    install_tailscale_macos
elif [[ "$OS" == "Linux" ]]; then
    # Linux specific checks
    if command -v tailscale &>/dev/null; then
        # Check Tailscale status
        status=$(sudo tailscale status)
        if [[ $status == *"Tailscale is stopped."* ]]; then
            echo "Tailscale is installed but stopped. Starting Tailscale..."
            echo "Please enter your Tailscale authorization key:"
            read -r TAILSCALE_AUTH_KEY
            sudo tailscale up --authkey="$TAILSCALE_AUTH_KEY" --operator="$USER"
        else
            echo "Tailscale is running."
        fi
    else
        install_tailscale_linux
    fi
else
    echo "Unsupported operating system."
    exit 1
fi