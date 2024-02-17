#!/usr/bin/env bash

# Source the common functions script
source "$(dirname "$BASH_SOURCE")/../init/init.sh"

add_brew_to_path

# Check if micro is installed
attempt_fix_command "micro" "$HOME/.local/bin"

while IFS= read -r package; do
    if [ -n "$package" ]; then  # Ensure the line is not empty
        if micro -plugin install "$package"; then
            echo_with_color "32" "${package} installed successfully"
        else
            exit_with_error "Failed to install ${package}"
        fi
    fi
done < <(get_package_list micro_plugins)
