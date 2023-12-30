#!/bin/bash

# Function to download and install chezmoi using curl or wget
install_chezmoi() {
    if command -v curl &> /dev/null; then
        sudo sh -c "$(curl -fsLS get.chezmoi.io)" -- -b /usr/local/bin
    elif command -v wget &> /dev/null; then
        sudo sh -c "$(wget -qO- get.chezmoi.io)" -- -b /usr/local/bin
    else
        echo "Error: neither curl nor wget is available."
        exit 1
    fi
}

# Install chezmoi
install_chezmoi

# Confirm the installation
if command -v chezmoi &> /dev/null; then
    echo "chezmoi installed successfully."
    # Execute chezmoi init
    chezmoi init --apply timmyb824
    if [ $? -eq 0 ]; then
        echo "chezmoi dotfiles have been applied successfully."

        # Remove the chezmoi binary as it will be reinstalled in a different way
        echo "Removing the chezmoi binary from /usr/local/bin..."
        sudo rm /usr/local/bin/chezmoi
        if [ $? -eq 0 ]; then
            echo "chezmoi binary removed successfully."
        else
            echo "Error: Failed to remove the chezmoi binary."
            exit 1
        fi
    else
        echo "Error: chezmoi dotfiles could not be applied."
        exit 1
    fi
else
    echo "Error: chezmoi installation failed."
    exit 1
fi