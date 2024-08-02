#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../init/init.sh"

OS=$(get_os)

clone_repositories_with_gitopolis() {
    if [ ! -f "$HOME/DEV/homelab/.gitopolis.toml" ]; then
        exit_with_error "No .gitopolis.toml file found at $HOME/DEV/homelab"
    fi

    # change into direcotry
    cd "$HOME/DEV/homelab" || exit_with_error "Unable to change into $HOME/DEV/homelab"
    if gitopolis clone; then
        echo_with_color "$GREEN_COLOR" "Successfully cloned repositories with gitopolis."
    else
        exit_with_error "Failed to clone repositories with gitopolis."
    fi

}

if [[ "$OS" == "MacOS" ]]; then
    add_brew_to_path
elif [[ "$OS" == "Linux" ]]; then
    attempt_to_fix_command "gitopolis" "$HOME/.local/bin"
else
    exit_with_error "Unsupported operating system: $OS"
fi

if ! command_exists gitopolis; then
    exit_with_error "gitopolis is still not available. Please install it first with homebrew."
fi

clone_repositories_with_gitopolis
