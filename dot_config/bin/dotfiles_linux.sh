#!/bin/bash

source "$(dirname "$BASH_SOURCE")/init.sh"

##### Consider storing linux dotfiles in their own private repo #####

# # ensure the shell is zsh and if not, try to switch to zsh
# if [ "$SHELL" != "/bin/zsh" ]; then
#     echo_with_color "31" "Your shell is not zsh. Attempting to switch to zsh..."
#     if [ -f "/bin/zsh" ]; then
#         chsh -s /bin/zsh
#     elif [ -f "/usr/bin/zsh" ]; then
#         chsh -s /usr/bin/zsh
#     else
#         echo_with_color "31" "Could not find zsh. Please install zsh and try again."
#         exit 1
#     fi
# fi

# Define the source and destination pairs (non-1password secret config files)
# indicate a dirtectory by adding a trailing slash
declare -A files_to_destinations=(
    ["$HOME/dotfiles/dot_config/atuin/"]="$HOME/.config/atuin"
    ["$HOME/dotfiles/dot_config/bat/"]="$HOME/.config/bat"
    ["$HOME/dotfiles/dot_config/broot/"]="$HOME/.config/broot"
    ["$HOME/dotfiles/dot_config/nvim/"]="$HOME/.config/nvim"
    ["$HOME/dotfiles/dot_config/starship/"]="$HOME/.config/starship"
    ["$HOME/dotfiles/dot_config/zsh/"]="$HOME/.config/zsh"
    ["$HOME/dotfiles/dot_config/zsh/executable_functions.zsh"]="$HOME/.config/zsh/functions.zsh"
    ["$HOME/dotfiles/dot_config/bin/dotfiles_linux/alias.zsh"]="$HOME/.config/zsh/alias.zsh"
    ["$HOME/dotfiles/dot_config/bin/dotfiles_linux/.zshrc"]="$HOME/.zshrc"
    ["$HOME/dotfiles/dot_config/bin/dotfiles_linux/.nanorc"]="$HOME/.nanorc"
    ["$HOME/dotfiles/dot_config/bin/dotfiles_linux/.gitconfig"]="$HOME/.gitconfig"
    # ["$HOME/dotfiles/dot_config/bin/dotfiles_linux/.ssh/config"]="$HOME/.ssh/config"
    # ["$HOME/dotfiles/dot_config/bin/dotfiles_linux/.ssh/id_master_key"]="$HOME/.ssh/id_master_key"
    # ["$HOME/dotfiles/dot_config/bin/dotfiles_linux/.ssh/id_master_key_nopass"]="$HOME/.ssh/id_master_key_nopass"
    # ["$HOME/dotfiles/dot_config/bin/dotfiles_linux/.oci/"]="$HOME/.oci"
)

# Function to copy files and directories
handle_files() {
    local action="$1"
    for source in "${!files_to_destinations[@]}"; do
        local destination="${files_to_destinations[$source]}"
        if [ "$action" == "copy" ]; then
            # Ensure destination directory exists
            local dest_dir
            if [ -d "$source" ]; then
                # If source is a directory, we use the destination directly
                dest_dir="$destination"
            else
                # If source is a file, we get the directory part of the destination
                dest_dir="$(dirname "$destination")"
            fi
            # Create destination directory if it doesn't exist
            mkdir -p "$dest_dir"

            # Now perform the copy operation
            echo_with_color "32" "Copying $source to $destination..."
            if [ -d "$source" ]; then
                # Use -a to preserve attributes and -T to not treat destination as directory
                cp -aT "$source" "$destination"
            else
                cp -f "$source" "$destination"
            fi
        elif [ "$action" == "remove" ]; then
            echo_with_color "32" "Removing $destination..."
            rm -rf "$destination"
        fi
    done
}

# Check for "remove" argument
if [ "$1" == "remove" ]; then
    handle_files "remove"
    echo_with_color "32" "dotfiles remove completed successfully."
    exit 0
fi

# Copy the configuration files to their destinations
handle_files "copy"
echo_with_color "32" "dotfiles copy completed successfully."