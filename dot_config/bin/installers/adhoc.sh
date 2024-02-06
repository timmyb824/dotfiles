#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../utilities/init.sh"

install_termium() {
    if command_exists termium; then
        echo_with_color "33" "Termium is already installed."
        exit 0
    else
        echo_with_color "32" "Installing Termium..."
        # Determine download tool
        if command_exists curl; then
            curl -L https://github.com/Exafunction/codeium/releases/download/termium-v0.2.0/install.sh | bash
        elif command_exists wget; then
            wget -O - https://github.com/Exafunction/codeium/releases/download/termium-v0.2.0/install.sh | bash
        else
            exit_with_error "Error: 'curl' or 'wget' is required to download files."
        fi
    fi
}

install_termium()
