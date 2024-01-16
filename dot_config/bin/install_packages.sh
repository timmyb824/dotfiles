#!/bin/bash

# Make sure we exit if there is a failure at any step
set -e

# Source common functions
source "$(dirname "$BASH_SOURCE")/init.sh"

# Function to make a script executable and run it
run_script() {
    local script=$1
    if ask_yes_or_no "Do you want to run $script?"; then
        echo "Running $script..."
        chmod +x "$SCRIPT_DIR/$script"  # Make the script executable
        "$SCRIPT_DIR/$script"         # Execute the script
        echo_with_color "32" "$script completed."
    else
        echo_with_color "33" "Skipping $script..."
    fi
}

# Start the installation process
echo "Starting package installations..."

run_script homebrew.sh
run_script pkgx.sh
run_script basher.sh
run_script krew.sh
run_script micro.sh
run_script python.sh
run_script pipx.sh
run_script nodejs.sh
run_script terraform.sh
run_script tailscale.sh
run_script zsh_install.sh
run_script 1password.sh
run_script dotfiles_linux.sh
# run_script fonts.sh

echo "All packages have been installed."