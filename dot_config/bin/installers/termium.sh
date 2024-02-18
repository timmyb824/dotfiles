#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../init/init.sh"

install_termium() {
    if command_exists termium; then
        exit_with_error "Termium is already installed."
    else
        echo_with_color "$GREEN" "Installing Termium..."
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

install_termium
