#!/bin/bash

# Make sure we exit if there is a failure at any step
set -e

# Function to update PATH for the current session
add_brew_to_path() {
    # Determine the system architecture for the correct Homebrew path
    local BREW_PREFIX
    if [[ "$(uname -m)" == "arm64" ]]; then
        BREW_PREFIX="/opt/homebrew/bin"
    else
        BREW_PREFIX="/usr/local/bin"
    fi

    # Construct the Homebrew path line
    local BREW_PATH_LINE="eval \"$(${BREW_PREFIX}/brew shellenv)\""

    # Check if Homebrew PATH is already in the PATH
    if ! echo "$PATH" | grep -q "${BREW_PREFIX}"; then
        echo "Adding Homebrew to PATH for the current session..."
        eval "${BREW_PATH_LINE}"
    fi
}

# Check if brew command is available
if ! command -v brew &> /dev/null; then
    echo "Homebrew not found. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to the current session's PATH
    add_brew_to_path
else
    echo "Homebrew is already installed."
fi

# Verify if Homebrew was successfully installed or already present
if ! command -v brew &> /dev/null; then
    echo "Error: Homebrew installation failed or PATH setup was not successful."
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

brew bundle --file=Brewfile

run_script pkgx.sh
run_script basher.sh
run_script krew.sh
run_script micro.sh
run_script npm.sh
run_script pipx.sh

echo "All packages have been installed."