#!/usr/bin/env bash

# Source the common functions script
source "$(dirname "$BASH_SOURCE")/../init/init.sh"
# Function to add krew to PATH for the current session if it's not already in the PATH
add_krew_to_path_for_session() {
    local krew_path="${KREW_ROOT:-$HOME/.krew}/bin"
    add_to_path_exact_match "$krew_path"
}

attempt_fix_command "kubectl" "$HOME/.local/bin"

# Check if krew is installed and working
if ! kubectl krew &> /dev/null; then
    echo_with_color "33" "krew could not be found or is not working properly, attempting to add to PATH for the current session"
    add_krew_to_path_for_session
    # Re-check if kubectl krew works after adding to PATH
    if ! kubectl krew &> /dev/null; then
        echo_with_color "31" "krew is still not working after attempting to add to PATH"
        exit 1
    fi
fi

# List of plugins to install
plugins=(
    "ctx"
    "ns"
)

# Iterate over the plugins and install one by one
for plugin in "${plugins[@]}"; do
    if ! kubectl krew list | grep -q "$plugin"; then
        echo_with_color "36" "Installing $plugin..."
        if kubectl krew install "$plugin"; then
            echo_with_color "32" "$plugin installed successfully"
        else
            echo_with_color "31" "Failed to install $plugin"
            exit 1
        fi
    else
        echo_with_color "34" "$plugin is already installed"
    fi
done
