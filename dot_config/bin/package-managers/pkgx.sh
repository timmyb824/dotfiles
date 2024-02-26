#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../init/init.sh"

# Function to install pkgx using Homebrew
install_pkgx() {
    if command_exists pkgx; then
        echo_with_color "$GREEN_COLOR" "pkgx is already installed."
        return
    fi

    if command_exists brew; then
        echo_with_color "$CYAN_COLOR" "Installing pkgx using Homebrew..."
        brew install pkgxdev/made/pkgx || exit_with_error "Installation of pkgx using Homebrew failed."
    else
        exit_with_error "Homebrew is not installed. Cannot install pkgx."
    fi
}

add_brew_to_path

# Install pkgx if it's not already available
if ! command_exists pkgx; then
    echo_with_color "$RED_COLOR" "pkgx could not be found"
    install_pkgx
fi

# Verify pkgx installation
command_exists pkgx || exit_with_error "pkgx installation failed."

# Define the array of packages that are common to both environments
common_packages=( $(get_package_list pkgx) )

# Define the array of additional packages for your personal computer
personal_packages=( $(get_package_list pkgx_personal) )

# Fetch the list of packages to install based on the hostname
hostname=$(hostname)
if [[ "$hostname" == "$WORK_HOSTNAME" ]]; then
    echo_with_color "$CYAN_COLOR" "Installing packages for work environment..."
    packages=( "${common_packages[@]}" )
else
    echo_with_color "$CYAN_COLOR" "Installing packages for personal environment..."
    packages=( "${personal_packages[@]}" "${common_packages[@]}" )
fi

# Define binary paths
mc_bin_path="$HOME/.local/bin/mc"
mcomm_bin_path="$HOME/.local/bin/mcomm"

echo_with_color "$CYAN_COLOR" "Installing packages..."

# Install packages using pkgx
for package in "${packages[@]}"; do
    output=$(pkgx install "${package}" 2>&1)

    if [[ "$output" == *"pkgx: installed:"* ]]; then
        echo_with_color "$GREEN_COLOR" "${package} installed successfully"
        if [[ "${package}" == "midnight-commander.org" ]]; then
            mv "$mc_bin_path" "$mcomm_bin_path" || exit_with_error "Failed to rename mc binary to mcomm."
            echo_with_color "$BLUE_COLOR" "Renamed mc binary to mcomm"
        fi
    elif [[ "$output" == *"pkgx: already installed:"* ]]; then
        echo_with_color "$YELLOW_COLOR" "${package} is already installed."
    else
        exit_with_error "Failed to install ${package}: $output"
    fi
done

# Add local binary path to PATH
add_to_path "$HOME/.local/bin"