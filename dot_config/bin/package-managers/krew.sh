#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../init/init.sh"

# Function to add krew to PATH for the current session if it's not already in the PATH
add_krew_to_path_for_session() {
    local krew_path="${KREW_ROOT:-$HOME/.krew}/bin"
    add_to_path_exact_match "$krew_path"
}

# Function to check if krew is installed and working
check_krew_installation() {
    if ! kubectl krew &> /dev/null; then
        echo_with_color "$YELLOW_COLOR" "krew could not be found or is not working properly, attempting to add to PATH for the current session"
        add_krew_to_path_for_session
        # Re-check if kubectl krew works after adding to PATH
        if ! kubectl krew &> /dev/null; then
            exit_with_error "krew is still not working after attempting to add to PATH"
        fi
    fi
}

# Function to install a krew plugin
install_krew_plugin() {
    local plugin=$1
    if ! kubectl krew list | grep -q "$plugin"; then
        echo_with_color "$CYAN_COLOR" "Installing $plugin..."
        if kubectl krew install "$plugin"; then
            echo_with_color "$GREEN_COLOR" "$plugin installed successfully"
        else
            exit_with_error "Failed to install $plugin"
        fi
    else
        echo_with_color "$BLUE_COLOR" "$plugin is already installed"
    fi
}

add_brew_to_path
# attempt_fix_command "kubectl" "$HOME/.local/bin"

check_krew_installation

# Get the list of plugins from the gist and install them
while IFS= read -r plugin; do
    trimmed_plugin=$(echo "$plugin" | xargs) # Trim whitespace from the plugin name
    if [ -n "$trimmed_plugin" ]; then # Ensure the line is not empty
        install_krew_plugin "$trimmed_plugin"
    fi
done < <(get_package_list krew)