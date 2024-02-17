#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../init/init.sh"

# Function to install Homebrew on macOS
install_brew_macos() {
    if ! command_exists brew; then
        echo_with_color "34" "Homebrew not found. Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || exit_with_error "Homebrew installation failed."
        add_brew_to_path
    else
        echo_with_color "32" "Homebrew is already installed."
    fi

    # Verify if Homebrew was successfully installed and available in the current session
    command_exists brew || exit_with_error "Homebrew installation failed or PATH setup was not successful."
}

# Function to update PATH for the current session
add_brew_to_path() {
    # Determine the system architecture for the correct Homebrew path
    local BREW_PREFIX
    if [[ "$(uname -m)" == "arm64" ]]; then
        BREW_PREFIX="/opt/homebrew/bin"
    else
        BREW_PREFIX="/usr/local/bin"
    fi

    # Check if Homebrew PATH is already in the PATH
    if ! echo "$PATH" | grep -q "${BREW_PREFIX}"; then
        echo_with_color "34" "Adding Homebrew to PATH for the current session..."
        eval "$(${BREW_PREFIX}/brew shellenv)"
    fi
}

# Prompt the user to install packages using Homebrew
install_packages_with_brew() {
    local temp_brewfile=$(mktemp)

    if ask_yes_or_no "Do you want to install the packages from the Brewfile?"; then
        # Fetch the Brewfile content using get_package_list and write to temp_brewfile
        get_package_list Brewfile > "$temp_brewfile" || exit_with_error "Failed to fetch Brewfile."

        # Check if the temporary Brewfile has content before proceeding
        if [ -s "$temp_brewfile" ]; then
            echo_with_color "34" "Installing packages from the Brewfile..."
            brew bundle --file="$temp_brewfile" || exit_with_error "Failed to install packages using the Brewfile."
        else
            exit_with_error "The fetched Brewfile is empty."
        fi

        # Clean up the temporary Brewfile
        rm "$temp_brewfile" || echo_with_color "33" "Warning: Failed to remove temporary Brewfile."
    else
        echo_with_color "33" "Skipping package installation."
        # Still clean up the empty temporary Brewfile
        rm "$temp_brewfile" || echo_with_color "33" "Warning: Failed to remove temporary Brewfile."
    fi
}

# Main execution for macOS
if [[ "$(get_os)" == "MacOS" ]]; then
    safe_remove_command "/usr/local/bin/op"
    install_brew_macos
    install_packages_with_brew
else
    exit_with_error "This script is intended for use on macOS only."
fi