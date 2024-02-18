#!/usr/bin/env bash

source_init_script

# Check for 'curl' command existence
if ! command_exists curl; then
    exit_with_error "Error: 'curl' is required to download files."
fi

# Function to install sops on macOS
install_sops_macos() {
    local sops_binary="sops-${SOPS_VERSION}.darwin.arm64"
    echo_with_color "$GREEN_COLOR" "Downloading sops binary for macOS..."
    curl -LO "https://github.com/mozilla/sops/releases/download/${SOPS_VERSION}/${sops_binary}"
    sudo mv "$sops_binary" /usr/local/bin/sops
    sudo chmod +x /usr/local/bin/sops
    echo_with_color "$GREEN_COLOR" "sops installed successfully on macOS."
}

# Function to install age on macOS
install_age_macos() {
    local age_archive="age-${AGE_VERSION}-darwin-arm64.tar.gz"
    echo_with_color "$GREEN_COLOR" "Downloading age binary for macOS..."
    curl -LO "https://github.com/FiloSottile/age/releases/download/${AGE_VERSION}/${age_archive}"
    tar -xvf "$age_archive"
    sudo mv age/age /usr/local/bin/age
    rm -rf age
    rm -f "$age_archive"
    echo_with_color "$GREEN_COLOR" "age installed successfully on macOS."
}

# Check and install sops if not installed
if command_exists sops; then
    echo_with_color "$YELLOW_COLOR" "sops is already installed on macOS."
else
    install_sops_macos
fi

# Check and install age if not installed
if command_exists age; then
    echo_with_color "$YELLOW_COLOR" "age is already installed on macOS."
else
    install_age_macos
fi