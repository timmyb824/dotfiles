#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../utilities/init.sh"

create_age_secret_key() {
    if [ ! -f "$AGE_SECRET_KEY_LOCATION" ]; then
        echo_with_color "32" "Creating age secret key..."
        if op read "$AGE_SECRET_KEY_FILE" 2>/dev/null > "$AGE_SECRET_KEY_LOCATION"; then
            echo_with_color "32" "Age secret key created successfully."
        else
            echo_with_color "31" "Failed to create age secret key."
            return 1
        fi
    else
        echo_with_color "33" "The age secret key already exists."
    fi
}

create_chezmoi_config() {
    if [ ! -f "$CHEZMOI_CONFIG_FILE" ]; then
        echo_with_color "32" "Creating chezmoi config file..."
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

# Ensure required variables are set
if [ -z "$AGE_SECRET_KEY_LOCATION" ] || [ -z "$AGE_SECRET_KEY_FILE" ] || [ -z "$CHEZMOI_CONFIG_FILE" ] || [ -z "$CHEZMOI_CONFIG_FILE_LOCATION" ]; then
    echo_with_color "31" "Required environment variables are not set."
    exit 1
fi

# Determine the OS
OS=$(get_os)

# Run the sign-in process
if 1password_sign_in; then
    # Always create the age secret key
    create_age_secret_key || exit_with_error "Unable to create age secret key." 2

    # For MacOS, also create the chezmoi config
    if [ "$OS" = "MacOS" ]; then
        create_chezmoi_config || exit_with_error "Unable to create chezmoi config file." 3
    fi
fi