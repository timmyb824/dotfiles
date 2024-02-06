#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../init/init.sh"
create_chezmoi_config() {
    if [ ! -f "$CHEZMOI_CONFIG_FILE_LOCATION" ]; then
        echo_with_color "32" "Creating chezmoi config file..."
        mkdir -p "$(dirname "$CHEZMOI_CONFIG_FILE_LOCATION")"
        if op read "$CHEZMOI_CONFIG_FILE" 2>/dev/null > "$CHEZMOI_CONFIG_FILE_LOCATION"; then
            echo_with_color "32" "Chezmoi config file created successfully."
        else
            echo_with_color "31" "Failed to create chezmoi config file."
            return 1
        fi
    else
        echo_with_color "33" "The chezmoi config file already exists."
    fi
}

# Ensure required chezmoi config variables are set
if [ -z "$CHEZMOI_CONFIG_FILE" ] || [ -z "$CHEZMOI_CONFIG_FILE_LOCATION" ]; then
    exit_with_error "Required chezmoi config environment variables are not set."
fi

# Determine the OS
OS=$(get_os)

# Only run this script for MacOS
if [ "$OS" = "MacOS" ]; then
    # Run the sign-in process
    if 1password_sign_in; then
        create_chezmoi_config || exit_with_error "Unable to create chezmoi config file." 3
    fi
else
    echo_with_color "33" "This script is intended to be run on MacOS only."
fi