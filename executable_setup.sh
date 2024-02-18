#!/usr/bin/env bash

# Source the common functions
source "dot_config/bin/init/init.sh"

# Define the path to the scripts
SCRIPT_DIR="dot_config/bin"
INSTALL_PACKAGES_SCRIPT="$SCRIPT_DIR/install.sh"
CHEZMOI_BIN="/usr/local/bin/chezmoi"

# Function to download and install chezmoi using curl or wget
install_chezmoi() {
    if command_exists chezmoi; then
        echo_with_color "$GREEN_COLOR" "chezmoi is already installed."
        return 0
    fi

    if command_exists curl; then
        sudo sh -c "$(curl -fsLS get.chezmoi.io)" -- -b /usr/local/bin
    elif command_exists wget; then
        sudo sh -c "$(wget -qO- get.chezmoi.io)" -- -b /usr/local/bin
    else
        exit_with_error "neither curl nor wget is available."
    fi

    echo_with_color "$GREEN_COLOR" "chezmoi has been installed successfully."
}

# Function to initialize and apply chezmoi dotfiles
initialize_chezmoi() {
    echo_with_color "$GREEN_COLOR" "Initializing chezmoi dotfiles."
    if "$CHEZMOI_BIN" init timmyb824/dotfiles && "$CHEZMOI_BIN" apply; then
        echo_with_color "$GREEN_COLOR" "chezmoi dotfiles have been applied successfully."
    else
        exit_with_error "chezmoi dotfiles could not be initialized or applied."
    fi
}

make_package_script_executable() {
    local script=$1
    if [ -f "$script" ] && [ ! -x "$script" ]; then
        echo "Making $(basename "$script") executable..."
        chmod +x "$script"
    fi
}

run_setup_scripts() {
    local script_path="$SCRIPT_DIR/$1"
    if [ -f "$script_path" ]; then
        echo "Running $1..."
        make_package_script_executable "$script_path"
        "$script_path" || exit_with_error "$1 failed to complete."
        echo_with_color "$GREEN_COLOR" "$1 completed."
    else
        exit_with_error "$1 does not exist."
    fi
}

package_installation() {
    if ask_yes_or_no "Do you want to install the packages?"; then
        make_package_script_executable "$INSTALL_PACKAGES_SCRIPT"
        echo "Running package installation script."
        "$INSTALL_PACKAGES_SCRIPT" || exit_with_error "Failed to execute package installation."
    else
        echo "Package installation skipped."
    fi
}

# Check if chezmoi and .zshrc already exist
if [[ -d "$HOME/.local/share/chezmoi" && -f "$HOME/.zshrc" ]]; then
    echo_with_color "$YELLOW_COLOR" "It appears chezmoi is already installed and initialized."
    package_installation # Install other packages
    exit 0
fi

echo_with_color "$GREEN_COLOR" "Proceeding with 1password, age, and sops installations:"
run_setup_scripts "installers/1password.sh"
run_setup_scripts "installers/age_sops.sh"

echo_with_color "$GREEN_COLOR" "Creating chezmoi config file..."
run_setup_scripts "configuration/chezmoi_config.sh"

echo_with_color "$GREEN_COLOR" "Creating age secret key..."
run_setup_scripts "configuration/age_secret.sh"

echo_with_color "$GREEN_COLOR" "Installing and initializing chezmoi..."
install_chezmoi
initialize_chezmoi

if ask_yes_or_no "Do you want to remove the chezmoi, sops, and age binaries?"; then
    echo_with_color "$BLUE_COLOR" "Removing binaries..."
    safe_remove_command "$CHEZMOI_BIN"
    safe_remove_command "/usr/local/bin/sops"
    safe_remove_command "/usr/local/bin/age"
else
    echo_with_color "$BLUE_COLOR" "Skipping binaries removal."
fi

package_installation

# Additional setup scripts can be run here as needed
# Example:
# run_setup_scripts "someadditional_script.sh"