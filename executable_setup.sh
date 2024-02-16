#!/usr/bin/env bash

# Source the common functions
source "dot_config/bin/init/init.sh"

# Define the path to the scripts
SCRIPT_DIR="dot_config/bin"
INSTALL_PACKAGES_SCRIPT="dot_config/bin/install.sh"
CHEZMOI_BIN="/usr/local/bin/chezmoi"

# Function to download and install chezmoi using curl or wget
install_chezmoi() {
    if command_exists chezmoi; then
        echo_with_color "32" "chezmoi is already installed."
        return 0
    fi

    if command_exists curl; then
        sudo sh -c "$(curl -fsLS get.chezmoi.io)" -- -b /usr/local/bin
        echo_with_color "32" "chezmoi has been installed successfully."
    elif command_exists wget; then
        sudo sh -c "$(wget -qO- get.chezmoi.io)" -- -b /usr/local/bin
        echo_with_color "32" "chezmoi has been installed successfully."
    else
        exit_with_error "neither curl nor wget is available."
    fi
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
        exit_with_error "chezmoi dotfiles could not be initialized."
    fi
}

run_setup_scripts() {
    local script=$1
    echo "Running $script..."
    chmod +x "$SCRIPT_DIR/$script"
    "$SCRIPT_DIR/$script"
    echo_with_color "32" "$script completed."
}

package_installation() {
    if ask_yes_or_no "Do you want to install the packages?"; then
        if [ -f "$INSTALL_PACKAGES_SCRIPT" ] && [ -x "$INSTALL_PACKAGES_SCRIPT" ]; then
            echo "Running package installation script."
            "$INSTALL_PACKAGES_SCRIPT" || exit_with_error "Failed to execute package installation."
        else
            exit_with_error "Package installation script does not exist or is not executable."
        fi
    else
        echo "Package installation skipped."
    fi
}

# Check if chezmoi and .zshrc already exist
CHEZMOI_INITIALIZED=false
if [[ -d "$HOME/.local/share/chezmoi" && -f "$HOME/.zshrc" ]]; then
    CHEZMOI_INITIALIZED=true
    echo_with_color "33" "It appears chezmoi is already installed and initialized."
fi

# Ask about proceeding with installation only if chezmoi is initialized
if $CHEZMOI_INITIALIZED; then
    if ! ask_yes_or_no "Do you still want to proceed with all installations including chezmoi initialization?"; then
        echo_with_color "34" "Skipping chezmoi installation and initialization."
        package_installation
        exit 0
    fi
fi

echo_with_color "32" "Proceeding with all installations:"
echo_with_color "32" "Installing 1password cli..."
run_setup_scripts "installers/1password.sh"

# Only run chezmoi scripts if not initialized
if ! $CHEZMOI_INITIALIZED; then
    echo_with_color "32" "Creating chezmoi config file..."
    run_setup_scripts "configuration/chezmoi_config.sh"

    echo_with_color "32" "Creating age secret key..."
    run_setup_scripts "configuration/age_secret.sh"
fi

if 1password_sign_in; then
    install_chezmoi
    initialize_chezmoi
else
    exit_with_error "Failed to sign into 1Password, which is required for chezmoi installation."
fi

if $CHEZMOI_INITIALIZED && ask_yes_or_no "Do you want to remove the chezmoi binary?"; then
    echo_with_color "34" "Removing chezmoi binary..."
    safe_remove_command $CHEZMOI_BIN
else
    echo_with_color "34" "Skipping chezmoi binary removal."
fi

package_installation

# Additional setup scripts can be run here as needed
# Example:
# run_setup_scripts "some_additional_script.sh"