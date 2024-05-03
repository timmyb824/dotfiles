#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../init/init.sh"

# Function to install micro editor plugin
install_gh_extension() {
    local extension=$1
    if gh extension install "$extension"; then
        echo_with_color "$GREEN_COLOR" "${extension} installed successfully"
    else
        # Instead of exiting, the script will report the error and continue with other plugins
        echo_with_color "$RED_COLOR" "Failed to install ${extension}"
    fi
}

add_brew_to_path

if ! command_exists gh; then
    exit_with_error "gh cli not found"
else
    echo_with_color "$GREEN_COLOR" "gh cli found continuing with extensions installation"
fi

# Read package list and install plugins
while IFS= read -r package; do
    # Trim whitespace and check if the line is not empty before attempting installation
    trimmed_package=$(echo "$package" | xargs)
    if [ -n "$trimmed_package" ]; then
        install_gh_extension "$trimmed_package"
    fi
done < <(get_package_list gh_cli)