#!/usr/bin/env bash

source_init_script

install_fonts_macos() {
    # Get the directory where your .ttf files are located from the parameter
    local font_dir="$1"
    # The destination directory for the fonts
    local user_font_dir="$HOME/Library/Fonts"

    # Copy each .ttf font file to the user's font directory
    echo_with_color "32" "Installing fonts from $font_dir..."
    find "$font_dir" -name "*.ttf" -exec cp "{}" "$user_font_dir" \;
    echo_with_color "32" "Fonts installed."
}

# Check if the script is running on macOS
if [ "$(get_os)" == "MacOS" ]; then
    install_fonts_macos "$HOME/.config/fonts/berkeley-mono-nerd-font" || exit_with_error "Could not install fonts berkeley-mono-nerd-font."
    install_fonts_macos "$HOME/.config/fonts/berkeley-mono-typeface/berkeley-mono/TTF" || exit_with_error "Could not install fonts berkeley-mono-typeface."
    install_fonts_macos "$HOME/.config/fonts/berkeley-mono-typeface/berkeley-mono-variable/TTF" || exit_with_error "Could not install fonts berkeley-mono-typeface."
else
    # If the operating system is not macOS, inform the user and exit
    echo_with_color "31" "Operating system not supported."
fi