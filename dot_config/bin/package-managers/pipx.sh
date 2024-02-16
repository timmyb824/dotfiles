#!/usr/bin/env bash

# Correct the source path if necessary and ensure init.sh is in the correct location
source "$(dirname "$BASH_SOURCE")/../init/init.sh"


install_pipx_packages() {
    while IFS= read -r package; do
        if [ -n "$package" ]; then  # Ensure the line is not empty
            if pipx install "$package"; then
                echo_with_color "32" "${package} installed successfully."
            else
                exit_with_error "Failed to install ${package}."
            fi
        fi
    done < <(get_package_list pipx)
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