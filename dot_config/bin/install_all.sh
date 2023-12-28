#!/bin/bash

# Make sure we exit if there is a failure at any step
set -e

# Check for Homebrew and install if not already installed
if ! command -v brew &> /dev/null; then
    echo "Homebrew not found. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Verify if Homebrew was successfully installed
if ! command -v brew &> /dev/null; then
    echo "Error: Homebrew installation failed."
    exit 1
fi

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

echo "Installing packages from Brewfile..."
brew bundle --file=Brewfile

# Run each of the .sh installers
run_script pkgx.sh
run_script basher.sh
run_script krew.sh
run_script micro.sh
run_script npm.sh
run_script pipx.sh

echo "All packages have been installed."
