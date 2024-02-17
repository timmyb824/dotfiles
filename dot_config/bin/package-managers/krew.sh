#!/usr/bin/env bash

# Source the common functions script
source "$(dirname "$BASH_SOURCE")/../init/init.sh"
# Function to add krew to PATH for the current session if it's not already in the PATH
add_krew_to_path_for_session() {
    local krew_path="${KREW_ROOT:-$HOME/.krew}/bin"
    add_to_path_exact_match "$krew_path"
}

add_brew_to_path
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

# Get the list of plugins from the gist and iterate over them
while IFS= read -r plugin; do
    trimmed_plugin=$(echo "$plugin" | xargs)  # Trim whitespace
    if [ -n "$trimmed_plugin" ]; then  # Ensure the line is not empty
        if ! kubectl krew list | grep -q "$trimmed_plugin"; then
            echo_with_color "36" "Installing $trimmed_plugin..."
            if kubectl krew install "$trimmed_plugin"; then
                echo_with_color "32" "$trimmed_plugin installed successfully"
            else
                echo_with_color "31" "Failed to install $trimmed_plugin"
                exit 1
            fi
        else
            echo_with_color "34" "$trimmed_plugin is already installed"
        fi
    fi
done < <(get_package_list krew)