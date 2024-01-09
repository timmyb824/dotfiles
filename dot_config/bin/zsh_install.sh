#!/bin/bash

#######################
#     Install Zsh     #
#######################

# Check for Zsh and install if not present
if ! command -v zsh &>/dev/null; then
    echo_with_color "33" "Zsh not found. Installing Zsh..."
    if [ "$OS" = "Linux" ]; then
        sudo apt-get update
        sudo apt-get install -y zsh
    else
        echo "Unknown operating system. Cannot install Zsh."
        exit 1
    fi
else
    echo "Zsh is already installed."
fi

# Check if the default shell is already Zsh
CURRENT_SHELL=$(getent passwd "$(whoami)" | cut -d: -f7)
if [ "$CURRENT_SHELL" != "$(command -v zsh)" ]; then
    echo "Changing the default shell to Zsh..."
    sudo chsh -s "$(which zsh)" "$(whoami)"
else
    echo_with_color "34" "Zsh is already the default shell."
fi

# Check if we're already running Zsh to prevent a loop
if [ -n "$ZSH_VERSION" ]; then
    echo_with_color "34" "Already running Zsh, no need to switch."
else
    # Executing the Zsh shell
    # The exec command replaces the current shell with zsh.
    # The "$0" refers to the script itself, and "$@" passes all the original arguments passed to the script.
    if [ -x "$(command -v zsh)" ]; then
        echo_with_color "34" "Switching to Zsh for the remainder of the script..."
        exec zsh -l "$0" "$@"
    fi
fi