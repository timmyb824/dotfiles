#!/usr/bin/env bash

source_init_script

# Function to download and install 1Password CLI on macOS
install_op_cli_macos() {
    if command_exists op; then
        echo_with_color "$YELLOW_COLOR" "The 1Password CLI is already installed."
        return 0 # Indicate that it's already installed
    fi

    echo_with_color "$GREEN_COLOR" "Installing the 1Password CLI for macOS..."

    # Check for required download commands
    if ! command_exists curl && ! command_exists wget; then
        echo_with_color "$RED_COLOR" "Error: 'curl' or 'wget' is required to download files."
        return 1
    fi

    # Determine download tool
    local download_cmd=""
    if command_exists curl; then
        download_cmd="curl -Lso"
    elif command_exists wget; then
        download_cmd="wget --quiet -O"
    fi

    # Download the latest release of the 1Password CLI
    local op_cli_pkg="op_apple_universal_v2.24.0.pkg"
    $download_cmd "$op_cli_pkg" "https://cache.agilebits.com/dist/1P/op2/pkg/v2.24.0/$op_cli_pkg"

    # Install the package
    sudo installer -pkg "$op_cli_pkg" -target /

    # Verify the installation
    if command_exists op; then
        echo_with_color "$GREEN_COLOR" "The 1Password CLI was installed successfully."
    else
        echo_with_color "$RED_COLOR" "Error: The 1Password CLI installation failed."
        return 1
    fi
}

install_op_cli_macos