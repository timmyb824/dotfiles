#!/bin/bash

# Make sure we exit if there is a failure at any step
set -e

# Function to make a script executable and run it
run_script() {
    local script=$1
    echo "Running $script..."
    chmod +x "$script"  # Make the script executable
    ./"$script"         # Execute the script
    echo "$script completed."
}

# Start the installation process
echo "Starting package installations..."

run_script zsh_install.sh
run_script homebrew.sh
run_script pkgx.sh
run_script dotfiles_linux.sh
run_script basher.sh
run_script krew.sh
run_script micro.sh
run_script nodejs.sh
run_script pipx.sh
run_script python.sh
run_script tailscale.sh
run_script terraform.sh


echo "All packages have been installed."