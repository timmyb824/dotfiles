#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../init/init.sh"

OS=$(get_os)

# # Function to install micro editor plugin
# install_micro_plugin() {
#     local plugin=$1
#     if micro -plugin install "$plugin"; then
#         echo_with_color "$GREEN_COLOR" "${plugin} installed successfully"
#     else
#         # Instead of exiting, the script will report the error and continue with other plugins
#         echo_with_color "$RED_COLOR" "Failed to install ${plugin}"
#     fi
# }

install_micro_plugin() {
    local plugin=$1
    output=$(micro -plugin install "$plugin" 2>&1)
    echo "$output"
    if output=$(echo "$output" | grep -i "already installed"); then
        echo_with_color "$YELLOW_COLOR" "${plugin} already installed, attempting to update"
        if micro -plugin update "$plugin"; then
            echo_with_color "$GREEN_COLOR" "${plugin} updated successfully"
        else
            echo_with_color "$RED_COLOR" "Failed to update ${plugin}"
        fi
    elif echo "$output" | grep -i "failed"; then
        echo_with_color "$RED_COLOR" "Failed to install ${plugin}"
        echo_with_color "$RED_COLOR" "$output"
    elif echo "$output" | grep -i "Unknown"; then
        echo_with_color "$YELLOW_COLOR" "${plugin} unknow"
    else
        echo_with_color "$GREEN_COLOR" "${plugin} installed successfully"
    fi
}

if [[ "$OS" == "MacOS" ]]; then
    add_brew_to_path
fi

if ! command_exists micro; then
    exit_with_error "micro not found"
else
    echo_with_color "$GREEN_COLOR" "micro found continuing with plugins installation"
fi

# Read package list and install plugins
while IFS= read -r package; do
    # Trim whitespace and check if the line is not empty before attempting installation
    trimmed_package=$(echo "$package" | xargs)
    if [ -n "$trimmed_package" ]; then
        install_micro_plugin "$trimmed_package"
    fi
done < <(get_package_list micro_plugins)