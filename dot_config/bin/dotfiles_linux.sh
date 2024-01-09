#!/bin/bash

##################################3##
# Install dotfiles without chezmmoi #
#####################################

# Define the source directory of your dotfiles and the target .config directory
DOTFILES_DIR="$HOME/dotfiles"
CONFIG_DIR="$HOME/.config"

# Create the .config directory if it doesn't exist
if [ ! -d "$CONFIG_DIR" ]; then
    echo "Creating $CONFIG_DIR..."
    mkdir -p "$CONFIG_DIR"
fi

# Copy each folder from dotfiles to the .config directory
for folder in "$DOTFILES_DIR"/*; do
    if [ -d "$folder" ]; then
        folder_name=$(basename "$folder")
        echo "Copying $folder_name to $CONFIG_DIR..."
        cp -r "$folder" "$CONFIG_DIR/$folder_name"
    fi
done

# Copy the .zshrc file to the home directory
echo "Copying .*rc files to $HOME..."
cp -f "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
cp -f "$DOTFILES_DIR/.nanorc" "$HOME/.nanorc"

# source "$HOME/.zshrc"

echo "Installation of dotfiles complete."