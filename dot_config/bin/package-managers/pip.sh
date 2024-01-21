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

initialize_pip() {
    # Check for pip in the common installation locations
    if command_exists pip; then
        echo_with_color "32" "pip is already installed."
    else
        # Attempt to initialize pip if it's installed but not in the PATH
        if [[ -x "$HOME/.pyenv/shims/pip" ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
            export PYENV_ROOT="$HOME/.pyenv"
            export PATH="$PYENV_ROOT/bin:$PATH"
            eval "$(pyenv init --path)"
            eval "$(pyenv init -)"
        else
            # pip is not installed, provide instructions to install it
            echo_with_color "33" "pip is not installed. Please run pyenv_python.sh first."
            exit_with_error "pip installation required"
        fi
    fi
}

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

initialize_pip
confirm_python_and_pip
install_pip_packages