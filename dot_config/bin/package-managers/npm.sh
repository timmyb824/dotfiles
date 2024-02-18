#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../init/init.sh"

# Function to initialize fnm for the current session
initialize_fnm_for_session() {
    eval "$(fnm env --use-on-cd)"
}

# Function to confirm Node version and npm availability
confirm_node_and_npm() {
    local version
    version=$(node --version 2>&1)
    if [[ "$version" == "v${NODE_VERSION}" ]]; then
        echo_with_color "$GREEN_COLOR" "Confirmed Node version ${version}."
    else
        exit_with_error "Node version ${version} does not match the desired version v${NODE_VERSION}."
    fi

    if ! command_exists npm; then
        exit_with_error "npm is not available."
    fi

    echo_with_color "$GREEN_COLOR" "npm is available."
}

# Function to install npm packages from a provided package list
install_npm_packages() {
    echo_with_color "$CYAN_COLOR" "Installing npm global packages..."

    while IFS= read -r package; do
        trimmed_package=$(echo "$package" | xargs)  # Trim whitespace from the package name
        if [ -n "$trimmed_package" ]; then  # Ensure the line is not empty
            if npm install -g "$trimmed_package"; then
                echo_with_color "$GREEN_COLOR" "${trimmed_package} installed successfully"
            else
                exit_with_error "Failed to install ${trimmed_package}"
            fi
        fi
    done < <(get_package_list npm)

    echo_with_color "$GREEN_COLOR" "All npm packages installed successfully."
}

# Main script logic
add_brew_to_path

# Ensure fnm and npm are installed and at the correct version
if ! command_exists npm; then
    echo_with_color "$RED_COLOR" "npm could not be found"

    attempt_fix_command fnm "$HOME/.local/bin"

    if ! command_exists fnm; then
        exit_with_error "fnm is still not found after attempting to fix the PATH. Please install Node.js to continue."
    fi

    echo_with_color "$YELLOW_COLOR" "Found fnm. Attempting to initialize it..."
    initialize_fnm_for_session

    if ! command_exists npm; then
        echo_with_color "$RED_COLOR" "npm could not be found after initializing fnm"

        if fnm install "${NODE_VERSION}"; then
            echo_with_color "$GREEN_COLOR" "Node.js ${NODE_VERSION} installed successfully"
            initialize_fnm_for_session
            if ! fnm use "${NODE_VERSION}"; then
                exit_with_error "Failed to use Node.js ${NODE_VERSION}, please check fnm setup"
            fi
        else
            exit_with_error "Failed to install Node.js ${NODE_VERSION}, please check fnm setup"
        fi
    fi
fi

# Now that npm is confirmed to be available, proceed with checking the version and installing packages
confirm_node_and_npm
install_npm_packages