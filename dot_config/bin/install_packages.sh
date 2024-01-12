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
        echo "$script completed."
    else
        echo "Skipping $script..."
    fi
}

# Function to run remaining scripts with zsh
run_remaining_scripts_with_zsh() {
    # Source the .zshrc file if it exists
    if [ -f "$HOME/.zshrc" ]; then
        source "$HOME/.zshrc"
    fi

    # Run the remaining scripts
    run_script basher.sh
    run_script krew.sh
    run_script micro.sh
    run_script nodejs.sh
    run_script pipx.sh
    run_script python.sh
    run_script tailscale.sh
    run_script terraform.sh

    echo "All packages have been installed."
}

# Start the installation process
echo "Starting package installations..."

run_script homebrew.sh
run_script pkgx.sh
run_script dotfiles_linux.sh

# Now switch to zsh and run the remaining scripts
if [ -n "$(command -v zsh)" ]; then
    zsh -c "$(declare -f run_script run_remaining_scripts_with_zsh); run_remaining_scripts_with_zsh"
else
    echo "zsh is not installed. Please install zsh and retry."
    exit 1
fi