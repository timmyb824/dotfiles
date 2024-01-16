#!/usr/bin/env bash

# Correct the source path if necessary and ensure init.sh is in the correct location
source "$(dirname "$BASH_SOURCE")/init.sh"

# List of packages to install
packages=(
    "poetry"
    "pyinfra"
)

install_pipx_packages() {
    # Iterate over the packages and install one by one
    for package in "${packages[@]}"; do
        if pipx install "${package}"; then
            echo_with_color "32" "${package} installed successfully"
        else
            echo_with_color "31" "Failed to install ${package}"
            exit 1
        fi
    done
}

# Function to add a directory to PATH
add_to_path() {
    PATH="$1:$PATH"
    export PATH
}

# Check if pipx is installed
if command_exists pipx; then
    install_pipx_packages
else
    echo_with_color "31" "pipx command not found, attempting to fix..."

    # Attempt to fix pipx command availability
    attempt_fix_command pipx "$HOME/.local/bin"

    # Check for pipx again
    if command_exists pipx; then
        install_pipx_packages
    else
        echo_with_color "31" "pipx is still not found after attempting to fix the PATH. Please install pipx to continue."
        exit 1
    fi
fi

echo_with_color "33" "pipx.sh completed successfully"