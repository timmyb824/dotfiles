#!/bin/bash

source "$(dirname "$BASH_SOURCE")/init.sh"


install_op_cli() {
    # Determine the system's architecture
    ARCH="amd64"

    # Get the latest 1Password CLI version number
    OP_VERSION="v$(curl https://app-updates.agilebits.com/check/1/0/CLI2/en/2.0.0/N -s | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+')"

    if [ -z "$OP_VERSION" ]; then
        echo "Error: Unable to retrieve the latest 1Password CLI version."
        return 1
    fi

    # Download and install the 1Password CLI
    curl -sSfo op.zip \
    "https://cache.agilebits.com/dist/1P/op2/pkg/${OP_VERSION}/op_linux_${ARCH}_${OP_VERSION}.zip" \
    && unzip -od /usr/local/bin/ op.zip \
    && chmod +x /usr/local/bin/op \
    && rm op.zip

    if [ $? -ne 0 ]; then
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

# Check if the OS is Linux and install op CLI if it's not already installed
if [ "$(get_os)" = "Linux" ]; then
    if command_exists op; then
        echo "The 1Password CLI is already installed."
    else
        echo "Installing the 1Password CLI..."
        install_op_cli
    fi
else
    echo "This script only supports Linux systems."
    exit 1
fi

# Rest of the script...