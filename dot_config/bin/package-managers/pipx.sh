#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../init/init.sh"

install_pipx_packages() {
    echo_with_color "$YELLOW_COLOR" "Installing pipx packages..."
    while IFS= read -r package; do
        if [ -z "$package" ]; then  # Skip empty lines
            continue
        fi

        if pipx install "$package"; then
            echo_with_color "$GREEN_COLOR" "${package} installed successfully."
        else
            exit_with_error "Failed to install ${package}."
        fi
    done < <(get_package_list pipx)
    echo_with_color "$GREEN_COLOR" "All pipx packages installed successfully."
}

# Function to ensure pipx is available and install it if necessary
ensure_pipx_installed() {
    if command_exists pipx; then
        return
    fi

    echo_with_color "$RED_COLOR" "pipx command not found, attempting to fix..."


    # Attempt to fix pipx command availability
    attempt_fix_command pipx "$HOME/.local/bin"

    # Check if pipx is available again
    if ! command_exists pipx; then
        exit_with_error "pipx is still not found after attempting to fix the PATH. Please install pipx to continue."
    fi
}

add_brew_to_path
ensure_pipx_installed
install_pipx_packages