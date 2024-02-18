#!/usr/bin/env bash

source_init_script

create_go_directories() {
    local created=false

    if [ ! -d "$HOME/go" ]; then
        echo_with_color $GREEN_COLOR "Creating go directory..."
        mkdir -p "$HOME/go" && created=true
        echo_with_color $GREEN_COLOR "Go directory created successfully."
    else
        echo_with_color $YELLOW_COLOR "The go directory already exists."
    fi

    if [ ! -d "$HOME/go/bin" ]; then
        echo_with_color $GREEN_COLOR "Creating go bin directory..."
        mkdir -p "$HOME/go/bin" && created=true
        echo_with_color $GREEN_COLOR "Go bin directory created successfully."
    else
        echo_with_color $YELLOW_COLOR "The go bin directory already exists."
    fi

    if [ "$created" = true ]; then
        add_to_path "$HOME/go/bin"
    fi
}

# Check if 'go' command exists in the PATH
if ! command_exists go; then
    echo_with_color $RED_COLOR "Go could not be found. Attempting to fix this..."

    attempt_fix_command "go" "$HOME/.local/bin"

    if command_exists go; then
        echo_with_color $YELLOW_COLOR "Go has been found after attempting to fix the PATH."
    else
        exit_with_error "Go is still not found after attempting to fix the PATH. Please install Go to continue."
    fi
fi

add_brew_to_path
echo_with_color $YELLOW_COLOR "Attempting to create go directories..."
create_go_directories || exit_with_error "Unable to create go directories." 2