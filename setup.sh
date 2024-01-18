#!/usr/bin/env bash

# Source the common functions
source "dot_config/bin/utilities/init.sh"

# Function to download and install chezmoi using curl or wget
install_chezmoi() {
    if command_exists chezmoi; then
        echo_with_color "32" "chezmoi is already installed."
        return 1
    fi

    if command_exists curl; then
        sudo sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$(dirname "$CHEZMOI_BIN")"
        echo_with_color "32" "chezmoi has been installed successfully."
    elif command_exists wget; then
        sudo sh -c "$(wget -qO- get.chezmoi.io)" -- -b "$(dirname "$CHEZMOI_BIN")"
        echo_with_color "32" "chezmoi has been installed successfully."
    else
        exit_with_error "neither curl nor wget is available."
    fi
}

# Function to prepare encryption files
prepare_encryption_files() {
    echo_with_color "32" "Preparing encryption files."
    "$PREPARE_ENCRYPTION_FILES" || exit_with_error "Failed to prepare encryption files."
}

# Function to initialize and apply chezmoi dotfiles
initialize_chezmoi() {
    echo_with_color "32" "Initializing chezmoi dotfiles."
    if "$CHEZMOI_BIN" init timmyb824; then
        echo_with_color "32" "chezmoi dotfiles have been downloaded successfully."
        if "$CHEZMOI_BIN" apply; then
            echo_with_color "32" "chezmoi dotfiles have been applied successfully."
        else
            exit_with_error "chezmoi dotfiles could not be applied."
        fi
    else
        exit_with_error "chezmoi dotfiles could not be applied."
    fi
}

# Define the path to the scripts
INSTALL_PACKAGES_SCRIPT="dot_config/bin/install.sh"
CHEZMOI_BIN="/usr/local/bin/chezmoi"

# make all shell scripts executable
chmod +x ./dot_config/bin/*.sh

# Determine the current operating system
OS=$(get_os)

# Proceed based on the OS
case "$OS" in
    "MacOS")
        echo_with_color "34" "Detected macOS."
        if install_chezmoi; then
            initialize_chezmoi
            safe_remove_command $CHEZMOI_BIN
        fi
        ;;
    "Linux")
        echo_with_color "32" "Detected Linux."
        echo_with_color "32" "Skipping chezmoi installation."
        ;;
    *)
        exit_with_error "Unsupported operating system."
        ;;
esac

# Ask for package installation
if ask_yes_or_no "Do you want to install the packages?"; then
    echo "Running $INSTALL_PACKAGES_SCRIPT script."
    "$INSTALL_PACKAGES_SCRIPT" || exit_with_error "Failed to execute $INSTALL_PACKAGES_SCRIPT."
else
    echo "Package installation skipped."
fi
