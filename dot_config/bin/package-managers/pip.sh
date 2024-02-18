#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../init/init.sh"

# Function to initialize pip on macOS
initialize_pip_macos() {
    if command_exists pip; then
        echo_with_color "$GREEN_COLOR" "pip is already installed."
        return
    fi

    local pip_path="$HOME/.pyenv/shims/pip"
    if [[ -x "$pip_path" ]]; then
        echo_with_color "$GREEN_COLOR" "Adding pyenv pip to PATH."
        export PYENV_ROOT="$HOME/.pyenv"
        export PATH="$PYENV_ROOT/bin:$PATH"
        eval "$(pyenv init --path)"
        eval "$(pyenv init -)"
    else
        echo_with_color "$YELLOW_COLOR" "pip is not installed. Please run pyenv_python.sh first."
        exit_with_error "pip installation required"
    fi
}

# Function to confirm Python version and pip availability
confirm_python_and_pip() {
    local version
    version=$(python -V 2>&1 | awk '{print $2}')
    if [[ "$version" == "$PYTHON_VERSION" ]]; then
        echo_with_color "$GREEN_COLOR" "Confirmed Python version ${version}."
    else
        exit_with_error "Python version ${version} does not match the desired version ${PYTHON_VERSION}."
    fi

    if command_exists pip; then
        echo_with_color "$GREEN_COLOR" "pip is available."
    else
        exit_with_error "pip is not available."
    fi
}

# Function to install pip packages
install_pip_packages() {
    while IFS= read -r package; do
        if [ -z "$package" ]; then  # Skip empty lines
            continue
        fi
        if pip install "$package"; then
            echo_with_color "$GREEN_COLOR" "${package} installed successfully."
        else
            exit_with_error "Failed to install ${package}."
        fi
    done < <(get_package_list pip)
}

add_brew_to_path
initialize_pip_macos
confirm_python_and_pip
install_pip_packages