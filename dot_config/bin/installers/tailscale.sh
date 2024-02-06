#!/usr/bin/env bash

###################################
# Check OS and Install Tailscale  #
###################################

source "$(dirname "$BASH_SOURCE")/../init/init.sh"
# Function to install tailscale on Linux
install_tailscale_linux() {
    if ask_yes_or_no "Tailscale is not installed. Would you like to install Tailscale?"; then
        read -sp "Please enter your Tailscale authorization key: " TAILSCALE_AUTH_KEY
        echo

        if command_exists curl; then
            echo_with_color "32" "Installing Tailscale..."
            RELEASE=$(lsb_release -cs)
            # Add the Tailscale repository signing key and repository
            curl -fsSL "https://pkgs.tailscale.com/stable/ubuntu/${RELEASE}.noarmor.gpg" | sudo tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null
            curl -fsSL "https://pkgs.tailscale.com/stable/ubuntu/${RELEASE}.tailscale-keyring.list" | sudo tee /etc/apt/sources.list.d/tailscale.list
        else
            exit_with_error "curl is not installed. Please install curl to proceed."
        fi

        # Update the package list and install Tailscale
        sudo apt-get update -y || exit_with_error "Failed to update package list. Exiting."

        sudo apt-get install tailscale -y || exit_with_error "Failed to install Tailscale. Exiting."

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

# Detect the operating system
OS=$(get_os)

if [[ "$OS" == "MacOS" ]]; then
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

    if command_exists mas; then
        install_tailscale_macos
    else
        echo_with_color "31" "mas-cli is not installed. Please install mas-cli to proceed."
        exit 1
    fi
elif [[ "$OS" == "Linux" ]]; then
    if command_exists tailscale; then
        status=$(sudo tailscale status)
        if [[ "$status" == *"Tailscale is stopped."* ]]; then
            echo_with_color "34" "Tailscale is installed but stopped. Starting Tailscale..."
            read -sp "Please enter your Tailscale authorization key: " TAILSCALE_AUTH_KEY
            echo
            sudo tailscale up --authkey="$TAILSCALE_AUTH_KEY" --operator="$USER"
        else
            echo_with_color "32" "Tailscale is running."
        fi
    else
        install_tailscale_linux
    fi
fi