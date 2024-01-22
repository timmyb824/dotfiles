#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../utilities/init.sh"

# Function to install fonts using the cloned repository
install_fonts_linux() {
    local fonts_dir=$1

    echo_with_color "32" "Installing fonts..."
    cd "$fonts_dir" || exit_with_error "Could not cd into nerd-fonts directory."
    for font in "Hack" "FiraCode" "JetBrainsMono"; do
        ./install.sh "$font" || exit_with_error "Could not install $font."
    done
    echo_with_color "32" "Fonts installed."
}

install_fonts_macos() {
    # Define the directory where your .ttf files are located
    FONT_DIR="$HOME/.config/fonts/berkeley-mono-nerd-font"

    # The destination directory for the fonts
    USER_FONT_DIR="$HOME/Library/Fonts"

    # Copy each .ttf font file to the user's font directory
    echo "Installing fonts..."
    find "$FONT_DIR" -name "*.ttf" -exec cp "{}" "$USER_FONT_DIR" \;
}

# Check if the script is running on Linux
if [ "$(get_os)" == "Linux" ]; then
    # Check if 'ghq' is installed and use it to get nerd-fonts
    if command_exists "ghq"; then
        ghq get https://github.com/ryanoasis/nerd-fonts
        nerd_fonts_dir="$(ghq list -p | grep nerd-fonts)"
        if [ -z "$nerd_fonts_dir" ]; then
            exit_with_error "Could not find nerd-fonts directory."
        fi
        install_fonts_linux "$nerd_fonts_dir"
    elif command_exists "git"; then
        # If 'ghq' isn't installed but 'git' is, then clone and install fonts using 'git'
        echo_with_color "32" "ghq not found. Falling back to git for downloading fonts..."
        git clone https://github.com/ryanoasis/nerd-fonts "$HOME/nerd-fonts" || exit_with_error "Could not clone nerd-fonts repository."
        install_fonts "$HOME/nerd-fonts"
    else
        # If neither 'ghq' nor 'git' is installed, exit with an error
        exit_with_error "Neither ghq nor git is installed."
    fi
elif [ "$(get_os)" == "macOS" ]; then
    # If the operating system is macOS, install fonts using the function defined above
    install_fonts_macos
else
    # If the operating system is not linux or macos, inform the user and exit
    echo_with_color "31" "Operating system not supported."
fi