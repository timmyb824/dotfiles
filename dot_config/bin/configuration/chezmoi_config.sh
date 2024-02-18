#!/usr/bin/env bash

source_init_script

create_chezmoi_config() {
    if [ ! -f "$CHEZMOI_CONFIG_FILE_LOCATION" ]; then
        echo_with_color $GREEN_COLOR "Creating chezmoi config file..."
        mkdir -p "$(dirname "$CHEZMOI_CONFIG_FILE_LOCATION")"
        if op read "$CHEZMOI_CONFIG_FILE" 2>/dev/null > "$CHEZMOI_CONFIG_FILE_LOCATION"; then
            echo_with_color $GREEN_COLOR "Chezmoi config file created successfully."
        else
            echo_with_color $RED_COLOR "Failed to create chezmoi config file."
            return 1
        fi
    else
        echo_with_color $YELLOW_COLOR "The chezmoi config file already exists."
    fi
}

# Ensure required chezmoi config variables are set
if [ -z "$CHEZMOI_CONFIG_FILE" ] || [ -z "$CHEZMOI_CONFIG_FILE_LOCATION" ]; then
    exit_with_error "Required chezmoi config environment variables are not set." 1
fi

# Run the sign-in process
if 1password_sign_in; then
    create_chezmoi_config || exit_with_error "Unable to create chezmoi config file." 3
else
    exit_with_error "1Password sign-in failed." 2
fi