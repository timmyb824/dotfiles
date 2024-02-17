#!/usr/bin/env bash

# Make sure we exit if there is a failure at any step
set -e

# Source common functions
source "$(dirname "$BASH_SOURCE")/init/init.sh"

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
echo "Starting package installations for macOS..."

SCRIPT_DIR="dot_config/bin"

run_script package-managers/homebrew.sh
run_script package-managers/pkgx.sh
run_script package-managers/basher.sh
run_script package-managers/krew.sh
run_script package-managers/micro.sh
run_script package-managers/pipx.sh
run_script installers/pyenv_python.sh
run_script package-managers/pip.sh
run_script installers/fnm_node.sh
run_script package-managers/npm.sh
run_script installers/tfenv_terraform.sh
run_script installers/tailscale.sh
run_script installers/rbenv_ruby.sh
run_script installers/atuin.sh
run_script configuration/go_directories.sh

echo "All macOS packages have been installed."