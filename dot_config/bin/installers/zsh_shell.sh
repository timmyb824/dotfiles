#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../init/init.sh"

# Function to install Zsh
install_zsh() {
    if ! command_exists zsh; then
        echo_with_color "$YELLOW_COLOR" "Zsh not found. Installing Zsh..."
        if sudo apt-get update && sudo apt-get install -y zsh; then
            echo_with_color "$GREEN_COLOR" "Zsh installed successfully."
        else
            exit_with_error "Failed to install Zsh."
        fi
    else
        echo_with_color "$GREEN_COLOR" "Zsh is already installed."
    fi
}

# Function to change default shell to Zsh
change_shell_to_zsh() {
    local zsh_path
    zsh_path=$(command -v zsh)
    if [ -z "$zsh_path" ]; then
        exit_with_error "Zsh command not found after installation."
    fi

    echo_with_color "$BLUE_COLOR" "Changing the default shell to Zsh..."
    if sudo chsh -s "$zsh_path" "$(whoami)"; then
        echo_with_color "$GREEN_COLOR" "Default shell changed to Zsh successfully."
    else
        exit_with_error "Failed to change the default shell to Zsh."
    fi
}

# Install Zsh if not present
install_zsh

# Change the default shell to Zsh if it isn't already
current_shell=$(getent passwd "$(whoami)" | cut -d: -f7)
if [ "$current_shell" != "$(command -v zsh)" ]; then
    change_shell_to_zsh
else
    echo_with_color "$BLUE_COLOR" "Zsh is already the default shell."
fi

# Check if we're already running Zsh to prevent a loop
# Not needed if the script is run in a non-interactive mode or if Zsh will become the default shell after a terminal restart
# if [ -n "$ZSH_VERSION" ]; then
#     echo_with_color "34" "Already running Zsh, no need to switch."
# else
#     # Executing the Zsh shell
#     # The exec command replaces the current shell with zsh.
#     # The "$0" refers to the script itself, and "$@" passes all the original arguments passed to the script.
#     if [ -x "$(command -v zsh)" ]; then
#         echo_with_color "34" "Switching to Zsh for the remainder of the script..."
#         exec zsh -l "$0" "$@"
#     fi
# fi
