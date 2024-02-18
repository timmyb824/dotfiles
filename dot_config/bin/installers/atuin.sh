#!/usr/bin/env bash

source_init_script

# Function to initialize atuin for zsh
initialize_atuin() {
    echo_with_color "$YELLOW_COLOR" "Initializing atuin..."
    eval "$(atuin init zsh)"
}

# Ensure brew is in the PATH
add_brew_to_path

# Main logic
if command_exists atuin; then
    echo_with_color "$GREEN_COLOR" "atuin is already installed."
    # Check if atuin is logged in
    if atuin status &> /dev/null; then
        if atuin status | grep -q "session not found"; then
            echo_with_color "$YELLOW_COLOR" "atuin is not logged in."
            atuin login -u "tbryant"
        else
            echo_with_color "$GREEN_COLOR" "atuin is already logged in."
        fi
    else
        echo_with_color "$RED_COLOR" "Unable to determine atuin status. Please check atuin configuration."
    fi
else
    # Attempt to fix atuin command availability
    attempt_fix_command atuin "$HOME/.local/bin"

    # Re-check for atuin
    if command_exists atuin; then
        echo_with_color "$YELLOW_COLOR" "Found atuin, initializing..."
        initialize_atuin
        atuin login -u "tbryant"
    else
        exit_with_error "atuin is still not found after attempting to fix the PATH. Please install atuin to continue."
    fi
fi