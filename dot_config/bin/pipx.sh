#!/bin/bash

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
        fi
    done
}

# Check if pipx is installed
if command_exists pipx; then
    install_pipx_packages
else
    echo_with_color "31" "pipx command not found"
fi

echo_with_color "33" "pipx.sh completed successfully"