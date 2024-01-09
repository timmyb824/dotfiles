#!/bin/bash

# Define the path to the install_packages.sh script
INSTALL_PACKAGES_SCRIPT="./dot_config/bin/install_packages.sh"

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

# Detect the operating system
OS="$(uname)"

if [ "$OS" = "Darwin" ]; then
    # macOS specific logic
    echo "Detected macOS. Installing chezmoi."
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

    echo "Running $INSTALL_PACKAGES_SCRIPT script."
    "$INSTALL_PACKAGES_SCRIPT"
    if [ $? -ne 0 ]; then
        echo "Error: Failed to execute $INSTALL_PACKAGES_SCRIPT."
        exit 1
    fi

elif [ "$OS" = "Linux" ]; then
    # Linux specific logic
    echo "Detected Linux. Skipping chezmoi installation."
    echo "Running $INSTALL_PACKAGES_SCRIPT script."
    "$INSTALL_PACKAGES_SCRIPT"
    if [ $? -ne 0 ]; then
        echo "Error: Failed to execute $INSTALL_PACKAGES_SCRIPT."
        exit 1
    fi
else
    echo "Unsupported operating system."
    exit 1
fi