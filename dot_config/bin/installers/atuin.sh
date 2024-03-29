#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../init/init.sh"

# Function to initialize atuin for zsh
initialize_atuin() {
    local shell_name
    shell_name=$(basename "$SHELL")

    if [ -z "$shell_name" ]; then
        echo_with_color "$RED_COLOR" "Unable to determine the shell for atuin initialization."
        exit_with_error "Shell not found for atuin initialization." 1
    else
        echo_with_color "$YELLOW_COLOR" "Initializing atuin for $shell_name..."
        eval "$(atuin init "$shell_name")"
    fi
}

login_to_atuin() {
    if atuin status &> /dev/null; then
        if atuin status | grep -q "cannot show sync status"; then
            echo_with_color "$YELLOW_COLOR" "atuin is not logged in."
            if atuin login -u "$ATUIN_USER"; then
                echo_with_color "$GREEN_COLOR" "atuin login successful."
            else
                echo_with_color "$RED_COLOR" "atuin login failed."
                exit_with_error "Failed to log in to atuin with user $ATUIN_USER." 2
            fi
        else
            echo_with_color "$GREEN_COLOR" "atuin is already logged in."
        fi
    else
        echo_with_color "$RED_COLOR" "Unable to determine atuin status. Please check atuin configuration."
        exit_with_error "Unable to determine atuin status." 1
    fi
}

# Ensure brew is in the PATH
add_brew_to_path

# Main logic
if command_exists atuin; then
    echo_with_color "$GREEN_COLOR" "atuin is already installed."
    echo_with_color "$YELLOW_COLOR" "Checking atuin status..."
    login_to_atuin
else
    echo_with_color "$RED_COLOR" "atuin could not be found."
    echo_with_color "$YELLOW_COLOR" "Installing atuin..."
    brew install atuin
    initialize_atuin
    echo_with_color "$GREEN_COLOR" "atuin installed successfully."
    login_to_atuin
fi