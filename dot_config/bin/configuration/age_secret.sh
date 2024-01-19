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

# Ensure required age secret key variables are set
if [ -z "$AGE_SECRET_KEY_LOCATION" ] || [ -z "$AGE_SECRET_KEY_FILE" ]; then
    echo_with_color "31" "Required age secret key environment variables are not set."
    exit 1
fi

# Run the sign-in process
if 1password_sign_in; then
    create_age_secret_key || exit_with_error "Unable to create age secret key." 2
fi