#!/bin/bash

# This script copies or symlinks the configuration files to their destinations.
# It also removes the files if the "remove" argument is (./script_name.sh remove)

source "$(dirname "$BASH_SOURCE")/init.sh"

# Define the source and destination pairs
declare -A files_to_destinations=(
    ["$HOME/dotfiles/.zshrc"]="$HOME/.zshrc"
    ["$HOME/dotfiles/.nanorc"]="$HOME/.nanorc"
    # add more file mappings here
)

# Function to copy or symlink files
handle_files() {
    local action="$1"
    for source in "${!files_to_destinations[@]}"; do
        local destination="${files_to_destinations[$source]}"
        if [ "$action" == "copy" ]; then
            echo "Copying $source to $destination..."
            cp -f "$source" "$destination"
        elif [ "$action" == "symlink" ]; then
            echo "Creating symlink from $source to $destination..."
            ln -sfn "$source" "$destination"
        elif [ "$action" == "remove" ]; then
            echo "Removing $destination..."
            rm -f "$destination"
        fi
    done
}

# Check for "remove" argument
if [ "$1" == "remove" ]; then
    handle_files "remove"
    exit 0
fi

# Ask user for copying or symlinking files
if ask_yes_or_no "Do you want to copy the configuration files to their destinations?"; then
    handle_files "copy"
elif ask_yes_or_no "Would you like to create symlinks to the configuration files instead?"; then
    handle_files "symlink"
else
    echo "No changes were made."
fi

echo "Operation completed."