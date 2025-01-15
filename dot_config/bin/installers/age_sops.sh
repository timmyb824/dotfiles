#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../init/init.sh"

OS=$(get_os)

# Check for 'curl' command existence
if ! command_exists curl; then
    exit_with_error "Error: 'curl' is required to download files."
fi

# Function to install sops on macOS
install_sops_macos() {
    if command_exists sops; then
        echo_with_color "$YELLOW_COLOR" "sops is already installed on macOS."
        return 0
    fi

    local sops_binary="sops-${SOPS_VERSION}.darwin.arm64"
    echo_with_color "$GREEN_COLOR" "Downloading sops binary for macOS..."
    curl -LO "https://github.com/mozilla/sops/releases/download/${SOPS_VERSION}/${sops_binary}"
    sudo mv "$sops_binary" /usr/local/bin/sops
    sudo chmod +x /usr/local/bin/sops
    echo_with_color "$GREEN_COLOR" "sops installed successfully on macOS."
}

# Function to install age on macOS
install_age_macos() {
    if command_exists age; then
        echo_with_color "$YELLOW_COLOR" "age is already installed on macOS."
        return 0
    fi

    local age_archive="age-${AGE_VERSION}-darwin-arm64.tar.gz"
    echo_with_color "$GREEN_COLOR" "Downloading age binary for macOS..."
    curl -LO "https://github.com/FiloSottile/age/releases/download/${AGE_VERSION}/${age_archive}"
    tar -xvf "$age_archive"
    sudo mv age/age /usr/local/bin/age
    rm -rf age
    rm -f "$age_archive"
    echo_with_color "$GREEN_COLOR" "age installed successfully on macOS."
}

# Function to install sops on Linux
install_sops_linux() {
    if command_exists sops; then
        echo_with_color "$YELLOW_COLOR" "sops is already installed on Linux."
        return 0
    fi

    echo_with_color "$GREEN_COLOR" "Downloading sops binary for Linux..."
    SOPS_BINARY="sops-${SOPS_VERSION}.linux.amd64"
    SOPS_URL="https://github.com/mozilla/sops/releases/download/${SOPS_VERSION}/${SOPS_BINARY}"

    if curl -LO "$SOPS_URL"; then
        sudo mv "$SOPS_BINARY" /usr/local/bin/sops
        sudo chmod +x /usr/local/bin/sops
        echo_with_color "$GREEN_COLOR" "sops installed successfully on Linux."
    else
        echo_with_color "$RED_COLOR" "Error: Failed to download sops from the URL: $SOPS_URL"
        return 1
    fi
}

# Function to install age on Linux
install_age_linux() {
    if command_exists age; then
        echo_with_color "$YELLOW_COLOR" "age is already installed on Linux."
        return 0
    fi

    echo_with_color "$GREEN_COLOR" "Downloading age binary for Linux..."
    AGE_BINARY="age-${AGE_VERSION}-linux-amd64.tar.gz"
    AGE_URL="https://github.com/FiloSottile/age/releases/download/${AGE_VERSION}/${AGE_BINARY}"

    if curl -LO "$AGE_URL"; then
        tar -xvf "$AGE_BINARY"
        sudo mv age/age /usr/local/bin/age
        rm -rf age "$AGE_BINARY"
        echo_with_color "$GREEN_COLOR" "age installed successfully on Linux."
    else
        echo_with_color "$RED_COLOR" "Error: Failed to download age from the URL: $AGE_URL"
        return 1
    fi
}

if [[ "$OS" == "MacOS" ]]; then
    install_sops_macos
    install_age_macos
elif [[ "$OS" == "Linux" ]]; then
    install_sops_linux
    install_age_linux
else
    exit_with_error "Unsupported operating system: $OS"
fi