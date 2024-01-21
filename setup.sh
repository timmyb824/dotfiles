#!/usr/bin/env bash

# Source the common functions
source "dot_config/bin/utilities/init.sh"

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

run_setup_scripts_macos() {
    local script=$1
    echo "Running $script..."
    chmod +x "$SCRIPT_DIR/$script"
    "$SCRIPT_DIR/$script"
    echo_with_color "32" "$script completed."
}

# Determine the current operating system
OS=$(get_os)

chmod +x "$SCRIPT_DIR"/install.sh

# Proceed based on the OS
case "$OS" in
"MacOS")
    echo_with_color "34" "Detected macOS."

    echo_with_color "32" "Installing 1password cli..."
    run_setup_scripts_macos "installers/1password.sh"

    # echo_with_color "32" "Installing age and sops..."
    # run_setup_scripts_macos "installers/age_sops.sh"

    echo_with_color "32" "Creating chezmoi config file..."
    run_setup_scripts_macos "configuration/chezmoi_config.sh"

    echo_with_color "32" "Creating age secret key..."
    run_setup_scripts_macos "configuration/age_secret.sh"

    if 1password_sign_in; then
        install_chezmoi
        initialize_chezmoi
    else
        exit_with_error "Failed to install chezmoi."
    fi

    echo_with_color "34" "Removing chezmoi binary..."
    safe_remove_command $CHEZMOI_BIN || exit_with_error "Failed to remove chezmoi binary."
    ;;
"Linux")
    echo_with_color "32" "Detected Linux."
    echo_with_color "32" "Skipping chezmoi installation."
    ;;
*)
    exit_with_error "Unsupported operating system."
    ;;
esac

# # Ask for package installation
# if ask_yes_or_no "Do you want to install the packages?"; then
#     echo "Running $INSTALL_PACKAGES_SCRIPT script."
#     "$INSTALL_PACKAGES_SCRIPT" || exit_with_error "Failed to execute $INSTALL_PACKAGES_SCRIPT."
# else
#     echo "Package installation skipped."
# fi

# Ask for package installation
if ask_yes_or_no "Do you want to install the packages?"; then
    if [ -f "$INSTALL_PACKAGES_SCRIPT" ] && [ -x "$INSTALL_PACKAGES_SCRIPT" ]; then
        echo "Running $INSTALL_PACKAGES_SCRIPT script."
        "$INSTALL_PACKAGES_SCRIPT" || exit_with_error "Failed to execute $INSTALL_PACKAGES_SCRIPT."
    else
        exit_with_error "$INSTALL_PACKAGES_SCRIPT does not exist or is not executable."
    fi
else
    echo "Package installation skipped."
fi
