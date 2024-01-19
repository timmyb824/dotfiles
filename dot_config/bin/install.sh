#!/usr/bin/env bash

# Make sure we exit if there is a failure at any step
set -e

# Source common functions
source "$(dirname "$BASH_SOURCE")/utilities/init.sh"

# Function to make a script executable and run it
run_script() {
    local script=$1
    if ask_yes_or_no "Do you want to run $script?"; then
        echo "Running $script..."
        chmod +x "$SCRIPT_DIR/$script"  # Make the script executable
        "$SCRIPT_DIR/$script"           # Execute the script
        echo_with_color "32" "$script completed."
    else
        echo_with_color "33" "Skipping $script..."
    fi
}

# Start the installation process
echo "Starting package installations..."

SCRIPT_DIR="dot_config/bin"

# Detect the operating system using get_os function
OS=$(get_os)

# Change the SCRIPT_DIR based on the OS detected
case $OS in
    MacOS)
        run_script package-managers/homebrew.sh
        run_script package-managers/pkgx.sh
        run_script package-managers/basher.sh
        run_script package-managers/krew.sh
        run_script package-managers/micro.sh
        run_script package-managers/python_pip.sh
        run_script package-managers/pipx.sh
        run_script package-managers/node_npm.sh
        run_script installers/terraform.sh
        run_script installers/tailscale.sh

        ;;
    Linux)
        run_script package-managers/pkgx.sh
        run_script package-managers/basher.sh
        run_script package-managers/krew.sh
        run_script package-managers/micro.sh
        run_script package-managers/python_pip.sh
        run_script package-managers/pipx.sh
        run_script package-managers/node_npm.sh
        run_script installers/terraform.sh
        run_script installers/tailscale.sh
        run_script installers/zsh_shell.sh
        run_script installers/1password.sh
        run_script installers/age_sops.sh
        run_script configuration/age_encryption.sh
        run_script dotfiles_linux/copy_dotfiles.sh
        run_script dotfiles_linux/process_dotfiles.sh
        ;;
    *)
        echo "Unsupported operating system: $OS"
        exit 1
        ;;
esac

echo "All packages have been installed."