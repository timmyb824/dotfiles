#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../init/init.sh"

install_plandex_cli() {
    if ! command_exists "plandex"; then
        echo_with_color "$YELLOW_COLOR" "plandex-cli is not installed."
        ask_yes_or_no "Do you want to install plandex-cli?"
        if [[ "$?" -eq 0 ]]; then
            if ! curl -sS https://plandex.ai/install.sh | bash; then
                echo_with_color "$RED_COLOR" "Failed to install plandex-cli."
            else
                echo_with_color "$GREEN_COLOR" "plandex-cli installed successfully."
            fi
        else
            echo_with_color "$GREEN_COLOR" "Skipping plandex-cli installation."
        fi
    else
        echo_with_color "$GREEN_COLOR" "plandex-cli is already installed."
    fi
}

# check for dependencies
if ! command_exists "curl"; then
    exit_with_error "curl is required"
fi

install_plandex_cli
