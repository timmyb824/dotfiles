#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../init/init.sh"

get_repositories() {
    while IFS= read -r package; do
        if [ -z "$package" ]; then  # Skip empty lines
            continue
        fi
        # extracts the repository name from the package URL without .git extension
        repo_name=$(echo "$package" | cut -d'/' -f2 | sed 's/\.git//')
        if ghq list | grep -q "$repo_name"; then
            echo "Repository $repo_name already cloned"
        else
            echo "Cloning $repo_name"
            if ghq get "$package"; then
                echo "Repository $repo_name cloned successfully"
            else
                echo "Failed to clone $repo_name"
            fi
        fi
    done < <(get_package_list ghq)
}

add_brew_to_path

if ! command_exists ghq; then
    exit_with_error "ghq is not available. Please install it first with homebrew."
fi

get_repositories


