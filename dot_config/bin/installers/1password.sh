#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../init/init.sh"

OS=$(get_os)

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

install_op_cli_linux() {
    if command_exists op; then
        echo_with_color "$YELLOW_COLOR" "The 1Password CLI is already installed."
        return 0 # Indicate that it's already installed
    fi

    if command_exists curl; then
        echo_with_color "$GREEN_COLOR" "The 'curl' command is installed."
    else
        echo_with_color "$BLUE_COLOR" "Installing the 'curl' command..."
        sudo apt update && sudo apt install -y curl
    fi

    # Install the 1Password CLI using the new steps provided
    if ! sudo sh -c 'curl -sS https://downloads.1password.com/linux/keys/1password.asc | \
gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg && \
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/$(dpkg --print-architecture) stable main" | \
tee /etc/apt/sources.list.d/1password.list && \
mkdir -p /etc/debsig/policies/AC2D62742012EA22/ && \
curl -sS https://downloads.1password.com/linux/debian/debsig/1password.pol | \
tee /etc/debsig/policies/AC2D62742012EA22/1password.pol && \
mkdir -p /usr/share/debsig/keyrings/AC2D62742012EA22 && \
curl -sS https://downloads.1password.com/linux/keys/1password.asc | \
gpg --dearmor --output /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg && \
apt update && apt install -y 1password-cli'; then
        echo_with_color "$RED_COLOR" "Error: The 1Password CLI installation failed."
        return 1
    fi

    if ! command_exists op; then
        echo_with_color "$RED_COLOR" "Error: The 'op' command does not exist after attempting installation."
        return 1
    else
        echo_with_color "$GREEN_COLOR" "The 1Password CLI was installed successfully."
    fi
}

if [[ "$OS" == "MacOS" ]]; then
  install_op_cli_macos
elif [[ "$OS" == "Linux" ]]; then
  install_op_cli_linux
else
  exit_with_error "Unsupported operating system: $OS"
fi