#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../init/init.sh"

# Check if necessary commands are available
if ! command_exists "curl" || ! command_exists "unzip"; then
    echo "curl and unzip are required"
    exit 1
fi

install_the_font() {
    local font_name="JetBrainsMono"
    local font_version="2.304"
    local font_url="https://download.jetbrains.com/fonts/JetBrainsMono-$font_version.zip"
    local font_dir="$HOME/.fonts/$font_name"
    local font_zip="/tmp/JetBrainsMono-$font_version.zip"

    # Check if the font is already installed
    if [ -d "$font_dir" ] && [ "$(ls -A "$font_dir")" ]; then
        echo "Font $font_name is already installed"
        return
    fi

    echo "Installing font $font_name"

    # Create directory for fonts if it doesn't exist
    mkdir -p "$font_dir" || exit_with_error "Failed to create font directory"

    # Download the font zip file
    curl -L -o "$font_zip" "$font_url" || exit_with_error "Failed to download font $font_name"

    # Unzip the font files to the font directory
    unzip -o "$font_zip" -d "$font_dir" || exit_with_error "Failed to unzip font $font_name"

    # Update the font cache
    if ! command_exists "fc-cache"; then
        echo_with_color "$YELLOW_COLOR" "fc-cache is required to update the font cache; installing now.."
        sudo apt-get install fontconfig -y || exit_with_error "Failed to install fontconfig"
    fi

    fc-cache -f -v "$font_dir" || exit_with_error "Failed to update font cache"

    echo_with_color "$GREEN_COLOR" "Font $font_name has been installed"

    # Clean up the zip file
    rm "$font_zip"
}

install_the_font
