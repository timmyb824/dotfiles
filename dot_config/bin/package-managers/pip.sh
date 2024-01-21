#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../utilities/init.sh"

# Pip packages to install
pip_packages=(
    "ansible"
    "gita"
    "pip-autoremove"
    "python-sysinformer"
    "sourcery"
    "spotify_to_ytmusic"
)

# Function to confirm Python version and pip availability
confirm_python_and_pip() {
    local version
    version=$(python -V 2>&1 | awk '{print $2}')
    if [[ "$version" == "${PYTHON_VERSION}" ]]; then
        echo_with_color "32" "Confirmed Python version ${version}."
    else
        exit_with_error "Python version ${version} does not match the desired version ${PYTHON_VERSION}."
    fi

    if command_exists pip; then
        echo_with_color "32" "pip is available."
    else
        exit_with_error "pip is not available."
    fi
}

# Function to install pip packages
install_pip_packages() {
    for package in "${pip_packages[@]}"; do
        if pip install "${package}"; then
            echo_with_color "32" "${package} installed successfully."
        else
            echo_with_color "31" "Failed to install ${package}."
        fi
    done
}

confirm_python_and_pip
install_pip_packages