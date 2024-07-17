#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../init/init.sh"

OS=$(get_os)

install_pkgx_macos() {
    add_brew_to_path
    if command_exists brew; then
        brew install pkgxdev/made/pkgx || exit_with_error "Installation of pkgx using Homebrew failed."
    else
        exit_with_error "Homebrew is not installed. Please install Homebrew and try again."
    fi
}

install_pkgx_linux() {
    # Ensure curl is installed before attempting to install pkgx
    if ! command_exists curl; then
        echo_with_color "$GREEN_COLOR" "curl is not installed. Installing curl..."
        sudo apt-get update || exit_with_error "Failed to update apt-get."
        sudo apt-get install -y curl || exit_with_error "Installation of curl failed."
    fi

    echo_with_color "$BLUE_COLOR" "Installing pkgx using curl..."
    curl -Ssf https://pkgx.sh | sh || exit_with_error "Installation of pkgx using curl failed."
}

# Function to prompt user for package list
prompt_for_package_list() {
    echo_with_color "$CYAN_COLOR" "Please select the package list you want to install:"
    echo "1) pkgx_all.list"
    echo "2) pkgx_mac.list"
    echo "3) pkgx_linux.list"
    read -rp "Enter the number (1-3): " choice

    case $choice in
        1) package_list="pkgx_all.list" ;;
        2) package_list="pkgx_mac.list" ;;
        3) package_list="pkgx_linux.list" ;;
        *) echo_with_color "$RED_COLOR" "Invalid selection. Exiting."
           exit 1 ;;
    esac
}

if ! command_exists pkgx; then
    echo_with_color "$YELLOW_COLOR" "pkgx could not be found"
    if [[ "$OS" == "MacOS" ]]; then
        install_pkgx_macos
    elif [[ "$OS" == "Linux" ]]; then
        install_pkgx_linux
    else
        exit_with_error "Unsupported OS: $OS"
    fi
fi

check_command pkgx

prompt_for_package_list

packages=( $(get_package_list "$package_list") )

mc_bin_path="$HOME/.local/bin/mc"
mcomm_bin_path="$HOME/.local/bin/mcomm"

echo_with_color "$CYAN_COLOR" "Installing packages..."

# Install packages using pkgx
for package in "${packages[@]}"; do
    output=$(pkgx install "${package}" 2>&1)

    if [[ "$output" == *"pkgx: installed:"* ]]; then
        echo_with_color "$GREEN_COLOR" "${package} installed successfully"
        # Check if the package is "midnight-commander.org", and user is privileged
        if [[ "${package}" == "midnight-commander.org" ]] && is_privileged_user; then
            mv "$mc_bin_path" "$mcomm_bin_path" || exit_with_error "Failed to rename mc binary to mcomm."
            echo_with_color "$BLUE_COLOR" "Renamed mc binary to mcomm"
        fi
    elif [[ "$output" == *"pkgx: already installed:"* ]]; then
        echo_with_color "$YELLOW_COLOR" "${package} is already installed."
    elif [[ "$output" == "nothing provides:"* ]]; then
        echo_with_color "$RED_COLOR" "Error: Package ${package} is not a valid package."
        echo_with_color "$YELLOW_COLOR" "Continuing with the next package..."
    elif [[ "$output" == *"already exists"* ]]; then
        echo_with_color "$RED_COLOR" "Error: Package ${package} already exists: $output"
        echo_with_color "$YELLOW_COLOR" "Continuing with the next package..."
    else
        echo_with_color "$RED_COLOR" "An unexpected error occurred: failed to install ${package}: $output"
        echo_with_color "$YELLOW_COLOR" "Continuing with the next package..."
    fi
done

# Add local binary path to PATH
add_to_path "$HOME/.local/bin"