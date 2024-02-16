#!/usr/bin/env bash

# Define safe_remove_command function and other necessary utilities
source "$(dirname "$BASH_SOURCE")/../init/init.sh"

# macOS specific SOPS and AGE versions
SOPS_VERSION="v3.7.1" # replace with the version you want to install
AGE_VERSION="v1.0.0" # replace with the version you want to install

# Function to install sops on macOS
install_sops_macos() {
    echo "Downloading sops binary for macOS..."
    SOPS_BINARY="sops-${SOPS_VERSION}.darwin.arm64"
    curl -LO "https://github.com/mozilla/sops/releases/download/${SOPS_VERSION}/${SOPS_BINARY}"
    sudo mv "$SOPS_BINARY" /usr/local/bin/sops
    sudo chmod +x /usr/local/bin/sops
    echo "sops installed successfully on macOS."
}

# Function to install age on macOS
install_age_macos() {
    echo "Downloading age binary for macOS..."
    curl -LO "https://github.com/FiloSottile/age/releases/download/${AGE_VERSION}/age-${AGE_VERSION}-darwin-arm64.tar.gz"
    tar -xvf "age-${AGE_VERSION}-darwin-arm64.tar.gz"
    sudo mv age/age /usr/local/bin/age
    rm -rf age
    echo "age installed successfully on macOS."
}

# Check and install sops if not installed
if command_exists sops; then
    echo "sops is already installed on macOS."
else
    install_sops_macos
fi

# Check and install age if not installed
if command_exists age; then
    echo "age is already installed on macOS."
else
    install_age_macos
fi