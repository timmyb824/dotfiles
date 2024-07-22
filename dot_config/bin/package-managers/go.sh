#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../init/init.sh"

OS=$(get_os)

install_go_packages_linux() {
    echo_with_color "$CYAN_COLOR" "Installing go packages..."

    while IFS= read -r package; do
        trimmed_package=$(echo "$package" | xargs)  # Trim whitespace from the package name
        if [ -n "$trimmed_package" ]; then  # Ensure the line is not empty
            output=$(go install "$trimmed_package")
            echo "$output"
            if [[ "$output" == *"Error"* ]]; then
                echo_with_color "$RED_COLOR" "Error: An unexpected error occurred while trying to install ${trimmed_package}: $output"
                echo_with_color "$YELLOW_COLOR" "Continuing with the next package..."
            else
                echo_with_color "$GREEN_COLOR" "${trimmed_package} installed successfully."
            fi
        fi
    done < <(get_package_list go_linux.list)
}

if [[ "$OS" == "Linux" ]]; then
    attempt_fix_command "go" "$HOME/.local/bin"
    if command_exists go; then
        echo_with_color "$CYAN_COLOR" "Go is installed, installing go packages..."
        install_go_packages_linux
    else
    echo_with_color "$RED_COLOR" "Go is not installed, skipping go packages installation..."
    exit_with_error "Please install Go to continue."
    fi
fi