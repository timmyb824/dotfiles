#!/usr/bin/env bash

# Define safe_remove_command function and other necessary utilities
source "$(dirname "$BASH_SOURCE")/init.sh"

# Functions to install sops and age
install_sops() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        SOPS_BINARY="sops-${SOPS_VERSION}.linux.amd64"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        SOPS_BINARY="sops-${SOPS_VERSION}.darwin.arm64"
    else
        echo "Unsupported OS type: $OSTYPE"
        exit 1
    fi

    echo "Downloading sops binary..."
    curl -LO "https://github.com/mozilla/sops/releases/download/${SOPS_VERSION}/${SOPS_BINARY}"
    mv "$SOPS_BINARY" /usr/local/bin/sops
    chmod +x /usr/local/bin/sops
    echo "sops installed successfully."
}

install_age() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        sudo apt install age
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "Downloading age binary..."
        curl -LO "https://dl.filippo.io/age/${AGE_VERSION}?for=darwin/arm64"
        mv "age-${AGE_VERSION}?for=darwin/arm64" /usr/local/bin/age
        chmod +x /usr/local/bin/age
    else
        echo "Unsupported OS type: $OSTYPE"
        exit 1
    fi
    echo "age installed successfully."
}

# Installation steps
install_sops
install_age

# Check if both sops and age are installed successfully
if command -v sops >/dev/null && command -v age >/dev/null; then
    read -p "Do you want to configure sops/age? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if [[ -f "../configuration/age_secret.sh" ]]; then
            bash "../configuration/age_secret.sh"
        else
            echo "Configuration script not found."
        fi
    fi
    # Post-installation cleanup for MacOS
    if [[ "$OSTYPE" == "darwin"* ]]; then
        safe_remove_command sops
        safe_remove_command age
    fi
else
    echo "Failed to install sops and/or age."
    exit 1
fi