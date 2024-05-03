#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../init/init.sh"

# create new install function that captures the output of the gh extension install command
install_gh_extension() {
    local extension=$1
    local output
    output=$(gh extension install "$extension" 2>&1)
    if [[ $output == *"already installed"* ]]; then
        echo_with_color "$YELLOW_COLOR" "${extension} already installed; attempting to update"
        output=$(gh extension upgrade "$extension" 2>&1)
        if [[ $output == *"upgraded"* ]]; then
            echo_with_color "$GREEN_COLOR" "${extension} updated successfully"
        elif [[ $output == *"already up to date"* ]]; then
            echo_with_color "$YELLOW_COLOR" "${extension} already up to date"
        else
            # Instead of exiting, the script will report the error and continue with other plugins
            echo_with_color "$RED_COLOR" "Failed to update ${extension}"
            echo_with_color "$RED_COLOR" "$output"
        fi
    elif [[ $output == *"Installed extension"* ]] || [[ $output == *"Cloning"* ]]; then
        echo_with_color "$GREEN_COLOR" "${extension} installed successfully"
    else
        # Instead of exiting, the script will report the error and continue with other plugins
        echo_with_color "$RED_COLOR" "Failed to install ${extension}"
        echo_with_color "$RED_COLOR" "$output"
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
