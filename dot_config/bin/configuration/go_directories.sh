#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../utilities/init.sh"

# if directors $HOME/go and $HOME/go/bin do not exist, create them
create_go_directories() {
    if [ ! -d "$HOME/go" ]; then
        echo_with_color "32" "Creating go directory..."
        mkdir -p "$HOME/go"
        echo_with_color "32" "Go directory created successfully."
    else
        echo_with_color "33" "The go directory already exists."
    fi

    if [ ! -d "$HOME/go/bin" ]; then
        echo_with_color "32" "Creating go bin directory..."
        mkdir -p "$HOME/go/bin"
        echo_with_color "32" "Go bin directory created successfully."
    else
        echo_with_color "33" "The go bin directory already exists."
    fi
}

if ! command_exists go; then
    echo_with_color "31" "Go could not be found."

    attempt_fix_command "go" "$HOME/.local/bin"

    if command_exists go; then
        echo_with_color "33" "Found go, attempting to create go directories..."
        create_go_directories || exit_with_error "Unable to create go directories." 2
    else
        echo_with_color "31" "Go is still not found after attempting to fix the PATH. Please install Go to continue."
        exit 1
    fi
else
    echo_with_color "32" "Go is already installed and working."
    echo_with_color "33" "Attempting to create go directories..."
    create_go_directories || exit_with_error "Unable to create go directories." 2
fi