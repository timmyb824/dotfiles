#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../init/init.sh"

# Function to install pyenv and pyenv-virtualenv using Homebrew for MacOS
install_pyenv_macos() {
    echo_with_color "32" "Installing pyenv and pyenv-virtualenv using Homebrew for MacOS..."

    # Check for Homebrew in the common installation locations
    if ! command_exists brew; then
        echo_with_color "31" "Homebrew could not be found. Attempting to add Homebrew to PATH..."
        add_brew_to_path
    else
        echo_with_color "32" "Homebrew is already installed."
    fi

    brew update
    brew install pyenv pyenv-virtualenv
}

# Function to install and set up Python version using pyenv
setup_python_version() {
    if pyenv install "${PYTHON_VERSION}"; then
        echo_with_color "32" "Python ${PYTHON_VERSION} installed successfully."

        if pyenv global "${PYTHON_VERSION}"; then
            echo_with_color "32" "Python ${PYTHON_VERSION} is now in use."
        else
            exit_with_error "Failed to set Python ${PYTHON_VERSION} as global, please check pyenv setup."
        fi
    else
        exit_with_error "Failed to install Python ${PYTHON_VERSION}, please check pyenv setup."
    fi
}

initialize_pyenv() {
    # Initialize pyenv for the current session
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init --path)"
    eval "$(pyenv init -)"
}

# Main installation process
if ! command_exists pyenv; then
    echo_with_color "32" "pyenv could not be found."

    if [[ "$(get_os)" == "MacOS" ]]; then
        install_pyenv_macos
        initialize_pyenv
        setup_python_version
    else
        exit_with_error "Unsupported operating system: $(get_os)"
    fi
else
    echo_with_color "32""pyenv is already installed."
    initialize_pyenv
    # Assuming that Python version is already set
fi