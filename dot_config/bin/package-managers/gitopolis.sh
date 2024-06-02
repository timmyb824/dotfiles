#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../init/init.sh"

clone_repositories_with_gitopolis() {
    if [ ! -f "$HOME/DEV/homelab/.gitopolis" ]; then
        exit_with_error "No .gitopolis file found at $HOME/DEV/homelab"
    fi

    # change into direcotry
    cd "$HOME/DEV/homelab" || exit_with_error "Unable to change into $HOME/DEV/homelab"
    if gitopolis clone; then
        echo_with_color "$GREEN_COLOR" "Successfully cloned repositories with gitopolis."
    else
        exit_with_error "Failed to clone repositories with gitopolis."
    fi

}

add_brew_to_path

if ! command_exists ghq; then
    add_to_path "$HOME/.local/bin"
    if ! command_exists ghq; then
        exit_with_error "ghq is still not available. Please install it first with homebrew."
    fi
fi

clone_repositories_with_gitopolis