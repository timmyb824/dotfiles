#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../init/init.sh"

initialize_atuin() {
    echo_with_color "33" "Initializing atuin..."
    eval "$(atuin init zsh)"
}

if command_exists atuin; then
    echo_with_color "32" "atuin is already installed"
    if atuin status | grep -q "session not found"; then
        echo_with_color "33" "atuin is not logged in"
        atuin login -u "tbryant"
    else
        echo_with_color "32" "atuin is already logged in"
    fi
else
    # Attempt to fix atuin command availability
    attempt_fix_command atuin "$HOME/.local/bin"

    # Check for atuin again
    if command_exists atuin; then
        echo_with_color "33" "Found atuin, initializing..."
        initialize_atuin
        atuin login -u "tbryant"
    else
        exit_with_error "atuin is still not found after attempting to fix the PATH. Please install atuin to continue."
    fi
fi