#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../init/init.sh"

# Function to install pkgx
install_pkgx() {
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
    echo "1) pkgx_code_server.list"
    echo "2) pkgx_work.list"
    echo "3) pkgx_personal.list"
    echo "4) pkgx_linux.list"
    read -rp "Enter the number (1-4): " choice

    case $choice in
        1) package_list="pkgx_code_server.list" ;;
        2) package_list="pkgx_work.list" ;;
        3) package_list="pkgx_personal.list" ;;
        4) package_list="pkgx_linux_all.list" ;;
        5) package_list="pkgx_linux_init.list" ;;
        6) package_list="pkgx_linux.list" ;;
        *) echo_with_color "$RED_COLOR" "Invalid selection. Exiting."
           exit 1 ;;
    esac
}

# Install pkgx if it's not already available
if ! command_exists pkgx; then
    echo_with_color "$RED_COLOR" "pkgx could not be found"
    install_pkgx
fi

# Verify pkgx installation
check_command pkgx

# Prompt user for the package list
prompt_for_package_list

# Fetch the selected package list
packages=( $(get_package_list "$package_list") )

# Define binary paths
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