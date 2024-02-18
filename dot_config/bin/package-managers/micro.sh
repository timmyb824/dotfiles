#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../init/init.sh"

# Function to install micro editor plugin
install_micro_plugin() {
    local plugin=$1
    if micro -plugin install "$plugin"; then
        echo_with_color "$GREEN_COLOR" "${plugin} installed successfully"
    else
        # Instead of exiting, the script will report the error and continue with other plugins
        echo_with_color "$RED_COLOR" "Failed to install ${plugin}"
    fi
}

# Function to attempt fixing the command, added for consistency
attempt_fix_micro_command() {
    attempt_fix_command "micro" "$HOME/.local/bin"
}

add_brew_to_path

attempt_fix_micro_command

# Read package list and install plugins
while IFS= read -r package; do
    # Trim whitespace and check if the line is not empty before attempting installation
    trimmed_package=$(echo "$package" | xargs)
    if [ -n "$trimmed_package" ]; then
        install_micro_plugin "$trimmed_package"
    fi
done < <(get_package_list micro_plugins)