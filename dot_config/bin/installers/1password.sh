#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../init/init.sh"

# Function to download and install 1Password CLI on macOS
install_op_cli_macos() {
    if command_exists op; then
        echo_with_color "33" "The 1Password CLI is already installed."
        return 0 # Indicate that it's already installed
    else
        echo_with_color "32" "Installing the 1Password CLI for macOS..."

        # Determine download tool
        if command_exists curl; then
            DOWNLOAD_CMD="curl -Lso"
        elif command_exists wget; then
            DOWNLOAD_CMD="wget --quiet -O"
        else
            echo_with_color "31" "Error: 'curl' or 'wget' is required to download files."
            return 1
        fi

        # Download the latest release of the 1Password CLI
        OP_CLI_PKG="op_apple_universal_v2.24.0.pkg"
        $DOWNLOAD_CMD "$OP_CLI_PKG" "https://cache.agilebits.com/dist/1P/op2/pkg/v2.24.0/$OP_CLI_PKG"

        # Install the package
        sudo installer -pkg "$OP_CLI_PKG" -target /

        # Verify the installation
        if command_exists op; then
            echo "The 1Password CLI was installed successfully."
        else
            echo "Error: The 1Password CLI installation failed."
            return 1
        fi
    fi
}

install_op_cli_macos