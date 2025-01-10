#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../init/init.sh"

initialize_pip() {
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

install_pipx_packages() {
    echo_with_color "$YELLOW_COLOR" "Installing pipx packages..."
    local failed_packages=()

    while IFS= read -r package; do
        if [ -z "$package" ]; then # Skip empty lines
            continue
        fi

        if pipx install "$package"; then
            echo_with_color "$GREEN_COLOR" "${package} installed successfully."
        else
            echo_with_color "$RED_COLOR" "Failed to install ${package}."
            failed_packages+=("$package")
        fi
    done < <(get_package_list pipx)

    if [ ${#failed_packages[@]} -eq 0 ]; then
        echo_with_color "$GREEN_COLOR" "All pipx packages installed successfully."
    else
        echo_with_color "$YELLOW_COLOR" "Installation completed with some failures:"
        for package in "${failed_packages[@]}"; do
            echo_with_color "$RED_COLOR" "  - ${package}"
        done
    fi
}

if command_exists pipx; then
    echo_with_color "$GREEN_COLOR" "pipx is already installed."
    install_pipx_packages
else
    echo_with_color "$YELLOW_COLOR" "pipx is not installed. Initializing pipx..."
    initialize_pip
    install_pipx_packages
fi
