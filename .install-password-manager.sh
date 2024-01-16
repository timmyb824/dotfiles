#!/usr/bin/env bash

# Source the common functions
source "$(dirname "$BASH_SOURCE")/dot_config/bin/init.sh"

# Function to install the 1Password CLI
install_op() {
    local install_script="./dot_config/bin/1password.sh"

    if [[ -f "$install_script" ]]; then
        echo_with_color "32" "Installing op."
        "$install_script" || exit_with_error "Failed to install op."
    else
        exit_with_error "Installation script for op does not exist: $install_script"
    fi
}

# Main execution
if command_exists op; then
    echo_with_color "32" "op is already installed."
else
    install_op
fi

# Exit with a successful code
exit 0
