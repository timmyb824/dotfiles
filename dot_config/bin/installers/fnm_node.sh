#!/usr/bin/env bash

# Source the common functions script
source "$(dirname "$BASH_SOURCE")/../init/init.sh"

# Function to initialize fnm for the current session
initialize_fnm_for_session() {
    # Initialize fnm without specifying a shell
    eval "$(fnm env --use-on-cd)"
}

# First, add the brew binary to the PATH if it's not already there
add_brew_to_path

# Check if npm is installed and working
if ! command_exists npm; then
    echo_with_color "31" "npm could not be found"

    # Attempt to fix fnm command availability
    attempt_fix_command fnm "$HOME/.local/bin"

    # Check for fnm again
    if command_exists fnm; then
        echo_with_color "33" "Found fnm, attempting to install Node.js ${NODE_VERSION}..."
        if fnm install "${NODE_VERSION}"; then
            echo_with_color "32" "Node.js ${NODE_VERSION} installed successfully"

            # Initialize fnm for the current session
            initialize_fnm_for_session

            if fnm use "${NODE_VERSION}"; then
                echo_with_color "32" "Node.js ${NODE_VERSION} is now in use"
            else
                exit_with_error "Failed to use Node.js ${NODE_VERSION}, please check fnm setup"
            fi
        else
            exit_with_error "Failed to install Node.js ${NODE_VERSION}, please check fnm setup"
        fi
    else
        exit_with_error "fnm is still not found after attempting to fix the PATH. Please install Node.js to continue."
    fi
else
    echo_with_color "32" "npm is already installed and working."
fi
