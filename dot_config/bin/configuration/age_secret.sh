#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../init/init.sh"

create_age_secret_key() {
    if [ ! -f "$AGE_SECRET_KEY_LOCATION" ]; then
        echo_with_color "$GREEN_COLOR" "Creating age secret key..."
        mkdir -p "$(dirname "$AGE_SECRET_KEY_LOCATION")"

        # Attempt to read the age secret key and store it in a variable
        local age_secret_key
        if age_secret_key=$(op read "$AGE_SECRET_KEY_FILE" 2>/dev/null); then
            echo "$age_secret_key" > "$AGE_SECRET_KEY_LOCATION"
            echo_with_color "$GREEN_COLOR" "Age secret key created successfully."
        else
            echo_with_color "$RED_COLOR" "Failed to create age secret key."
            return 1
        fi
    else
        echo_with_color "$YELLOW_COLOR" "The age secret key already exists."
    fi
}

# Function that creates the age secret key file by echoing the secret key into the file using the age credential
create_age_secret_key_file_unprivileged() {
    if [ ! -f "$AGE_SECRET_KEY_LOCATION" ]; then
        echo_with_color $GREEN_COLOR "Creating age secret key..."
        mkdir -p "$(dirname "$AGE_SECRET_KEY_LOCATION")"

        # Attempt to read the age secret key and store it in a variable
        local age_secret_key_credential
        local age_secret_key_recipient
        if age_secret_key_credential=$(op read "$AGE_SECRET_KEY" 2>/dev/null) && age_secret_key_recipient=$(op read "$AGE_RECIPIENT" 2>/dev/null); then
            # The heredoc delimiter must be unquoted to allow variable expansion.
            # Also, the delimiter must be at the beginning of the line with no leading whitespace.
            sudo tee "$AGE_SECRET_KEY_LOCATION" > /dev/null <<EOF
# created: $(date -Iseconds)
# public key: ${age_secret_key_recipient}
${age_secret_key_credential}
EOF
            echo_with_color $GREEN_COLOR "Age secret key created successfully."
        else
            echo_with_color $RED_COLOR "Failed to create age secret key."
            return 1
        fi
    else
        echo_with_color $YELLOW_COLOR "The age secret key already exists."
    fi
}

# Ensure required age secret key variables are set
if [ -z "$AGE_SECRET_KEY_LOCATION" ] || [ -z "$AGE_SECRET_KEY_FILE" ]; then
    exit_with_error "Required age secret key environment variables are not set."
fi

if 1password_sign_in; then
    if is_privileged_user; then
        create_age_secret_key_file || exit_with_error "Unable to create age secret key."
    else
        create_age_secret_key_file_unprivileged || exit_with_error "Unable to create age secret key."
    fi
else
    exit_with_error "Failed to sign in to 1Password."
fi