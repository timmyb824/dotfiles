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

if command_exists go; then
    create_go_directories || exit_with_error "Unable to create go directories." 2
else
    echo_with_color "33" "Go is not installed."
fi