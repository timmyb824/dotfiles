#!/bin/bash

source "$(dirname "$BASH_SOURCE")/init.sh"

##### Consider storing linux dotfiles in thier own private repo #####

# Define the source and destination pairs
# indicate a dirtectory by adding a trailing slash
declare -A files_to_destinations=(
    ["$HOME/dotfiles/.zshrc"]="$HOME/.zshrc"
    ["$HOME/dotfiles/.nanorc"]="$HOME/.nanorc"
    ["$HOME/dotfiles/.aicommits"]="$HOME/.aicommits"
    ["$HOME/dotfiles/.gitconfig"]="$HOME/.gitconfig"
    ["$HOME/dotfiles/.opencommit"]="$HOME/.opencommit"
    ["$HOME/dotfiles/.ssh/config"]="$HOME/.ssh/config"
    ["$HOME/dotfiles/.ssh/id_master_key"]="$HOME/.ssh/id_master_key"
    ["$HOME/dotfiles/.ssh/id_master_key_nopass"]="$HOME/.ssh/id_master_key_nopass"
    ["$HOME/dotfiles/.oci/"]="$HOME/.oci"
    ["$HOME/dotfiles/.config/atuin/"]="$HOME/.config/atuin"
    ["$HOME/dotfiles/.config/bat/"]="$HOME/.config/bat"
    ["$HOME/dotfiles/.config/gitearc/"]="$HOME/.config/gitearc"
    ["$HOME/dotfiles/.config/nvim/"]="$HOME/.config/nvim"
    ["$HOME/dotfiles/.config/starship/"]="$HOME/.config/starship"
    ["$HOME/dotfiles/.config/zsh/"]="$HOME/.config/zsh"
)

# Function to copy or symlink files and directories
handle_files() {
    local action="$1"
    for source in "${!files_to_destinations[@]}"; do
        local destination="${files_to_destinations[$source]}"
        if [ -d "$source" ]; then
            # It's a directory
            if [ "$action" == "copy" ]; then
                echo_with_color "32" "Copying directory $source to $destination..."
                cp -a "$source" "$destination"
            elif [ "$action" == "symlink" ]; then
                echo_with_color "32" "Creating symlink from directory $source to $destination..."
                ln -sfn "$source" "$destination"
            elif [ "$action" == "remove" ]; then
                echo_with_color "32" "Removing directory $destination..."
                rm -rf "$destination"
            fi
        else
            # It's a file
            if [ "$action" == "copy" ]; then
                echo_with_color "32" "Copying file $source to $destination..."
                cp -f "$source" "$destination"
            elif [ "$action" == "symlink" ]; then
                echo_with_color "32" "Creating symlink from file $source to $destination..."
                ln -sfn "$source" "$destination"
            elif [ "$action" == "remove" ]; then
                echo_with_color "32" "Removing file $destination..."
                rm -f "$destination"
            fi
        fi
    done
}

# Check for "remove" argument
if [ "$1" == "remove" ]; then
    handle_files "remove"
    echo_with_color "32" "dotfiles_linux.sh completed successfully."
    exit 0
fi

# Ask user for copying or symlinking files
if ask_yes_or_no "Do you want to copy the configuration files to their destinations?"; then
    handle_files "copy"
elif ask_yes_or_no "Would you like to create symlinks to the configuration files instead?"; then
    handle_files "symlink"
else
    echo_with_color "34" "No changes were made."
fi

echo_with_color "32" "dotfiles_linux.sh completed successfully."