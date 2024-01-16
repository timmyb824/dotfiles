#!/usr/bin/env bash

# Source the common functions
source "$(dirname "$BASH_SOURCE")/dot_config/bin/init.sh"

# Function to download and install chezmoi using curl or wget
install_chezmoi() {
    if ! command_exists chezmoi; then
        if command_exists curl; then
            sudo sh -c "$(curl -fsLS get.chezmoi.io)" -- -b /usr/local/bin
        elif command_exists wget; then
            sudo sh -c "$(wget -qO- get.chezmoi.io)" -- -b /usr/local/bin
        else
            exit_with_error "neither curl nor wget is available."
        fi
        return 0
    else
        echo_with_color "32" "chezmoi is already installed."
        return 1
    fi
}

# Define the path to the install_packages.sh script
INSTALL_PACKAGES_SCRIPT="./dot_config/bin/install_packages.sh"

# make all shell scripts excutable
chmod +x ./dot_config/bin/*.sh

# Determine the current operating system
OS=$(get_os)

if [ "$OS" = "MacOS" ]; then
    echo_with_color "34" "Detected macOS."
    install_chezmoi

    # Run chezmoi init only if it was just installed
    if [ $? -eq 0 ]; then
        chezmoi init --apply timmyb824
        if [ $? -eq 0 ]; then
            echo_with_color "32" "chezmoi dotfiles have been applied successfully."
        else
            exit_with_error "chezmoi dotfiles could not be applied."
        fi
    fi

elif [ "$OS" = "Linux" ]; then
    echo_with_color "32" "Detected Linux."
    echo_with_color "32" "Skipping chezmoi installation."
fi

# Run install_packages script regardless of the OS or chezmoi installation if the user wants to
if ask_yes_or_no "Do you want to install the packages?"; then
    echo "Running $INSTALL_PACKAGES_SCRIPT script."
    if ! "$INSTALL_PACKAGES_SCRIPT"; then
        exit_with_error "Failed to execute $INSTALL_PACKAGES_SCRIPT."
    fi
else
    echo "Package installation skipped."
fi