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

install_op_cli_linux() {
    # Install the 1Password CLI using the new steps provided
    if ! sudo -s -- <<EOF
curl -sS https://downloads.1password.com/linux/keys/1password.asc | \
gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/$(dpkg --print-architecture) stable main" | \
tee /etc/apt/sources.list.d/1password.list
mkdir -p /etc/debsig/policies/AC2D62742012EA22/
curl -sS https://downloads.1password.com/linux/debian/debsig/1password.pol | \
tee /etc/debsig/policies/AC2D62742012EA22/1password.pol
mkdir -p /usr/share/debsig/keyrings/AC2D62742012EA22
curl -sS https://downloads.1password.com/linux/keys/1password.asc | \
gpg --dearmor --output /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg
apt update && apt install -y 1password-cli
EOF
    then
        echo "Error: The 1Password CLI installation failed."
        return 1
    fi

    if ! command_exists op; then
        echo "Error: The 'op' command does not exist after attempting installation."
        return 1
    else
        echo "The 1Password CLI was installed successfully."
    fi
}

OS=$(get_os)
INSTALL_SUCCESS=0 # Default value assuming success

if [ "$OS" = "Linux" ]; then
    if ! command_exists op; then
        echo "Installing the 1Password CLI for Linux..."
        install_op_cli_linux
        INSTALL_SUCCESS=$?
    else
        echo "The 1Password CLI is already installed."
    fi
elif [ "$OS" = "MacOS" ]; then
    install_op_cli_macos
    INSTALL_SUCCESS=$?
else
    echo "This script only supports Linux and macOS systems."
    exit 1
fi

# Exit if installation failed or if we're on macOS (no further steps required)
if [ "$INSTALL_SUCCESS" -ne 0 ] || [ "$OS" = "Darwin" ]; then
    echo "Installation failed or completed for macOS. Exiting."
    exit $INSTALL_SUCCESS
fi