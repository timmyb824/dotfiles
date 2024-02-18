#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../init/init.sh"

# Function to install pyenv and pyenv-virtualenv using Homebrew for MacOS
install_pyenv_macos() {
    echo_with_color "$GREEN_COLOR" "Installing pyenv and pyenv-virtualenv using Homebrew for MacOS..."

    # Check if Homebrew is available
    if ! command_exists brew; then
        exit_with_error "Homebrew could not be found. Please install Homebrew to continue."
    fi

    brew update
    brew install pyenv pyenv-virtualenv

    if ! command_exists pyenv; then
        exit_with_error "pyenv installation failed."
    fi
}

# Function to install and set up Python version using pyenv
setup_python_version() {
    if pyenv install -s "${PYTHON_VERSION}"; then
        echo_with_color "$GREEN_COLOR" "Python ${PYTHON_VERSION} installed successfully."
    else
        exit_with_error "Failed to install Python ${PYTHON_VERSION}, please check pyenv setup."
    fi

    if pyenv global "${PYTHON_VERSION}"; then
        echo_with_color "$GREEN_COLOR" "Python ${PYTHON_VERSION} is now in use."
    else
        exit_with_error "Failed to set Python ${PYTHON_VERSION} as global, please check pyenv setup."
    fi
}

initialize_pyenv() {
    # Initialize pyenv for the current session
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init --path)"
    eval "$(pyenv init -)"
}

# Check if PYTHON_VERSION is provided
if [ -z "${PYTHON_VERSION}" ]; then
    exit_with_error "PYTHON_VERSION is not set. Please specify the Python version to install."
fi

# Ensure Homebrew is in PATH
add_brew_to_path

# Main installation process
if ! command_exists pyenv; then
    echo_with_color "$GREEN_COLOR" "pyenv could not be found. Starting installation process..."
    install_pyenv_macos
else
    echo_with_color "$GREEN_COLOR" "pyenv is already installed."
fi

initialize_pyenv
setup_python_version