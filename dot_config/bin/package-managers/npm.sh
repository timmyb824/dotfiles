#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../init/init.sh"

# Function to initialize fnm for the current session
initialize_fnm_for_session() {
    eval "$(fnm env --use-on-cd)"
}

# Function to exit with error
exit_with_error() {
    echo_with_color "31" "$1" 1>&2
    exit 1
}

# Function to confirm Node version and npm availability
confirm_node_and_npm() {
    local version
    version=$(node --version 2>&1)
    if [[ "$version" == "${NODE_VERSION}" ]]; then
        echo_with_color "32" "Confirmed Node version ${version}."
    else
        exit_with_error "Node version ${version} does not match the desired version v${NODE_VERSION}."
    fi

    if ! command_exists npm; then
        exit_with_error "npm is not available."
    fi

    echo_with_color "32" "npm is available."
}

# Function to install npm packages
install_npm_packages() {
    echo_with_color "36" "Installing npm global packages..."

    while IFS= read -r package; do
        if [ -n "$package" ]; then  # Ensure the line is not empty
            if npm install -g "$package"; then
                echo_with_color "32" "${package} installed successfully"
            else
                exit_with_error "Failed to install ${package}"
            fi
        fi
    done < <(get_package_list npm)

    echo_with_color "32" "All npm packages installed successfully."
}

# Main script logic
# First, add Brew to the PATH if it's not already there
add_brew_to_path

if ! command_exists npm; then
    echo_with_color "31" "npm could not be found"

    attempt_fix_command fnm "$HOME/.local/bin"

    if ! command_exists fnm; then
        exit_with_error "fnm is still not found after attempting to fix the PATH. Please install Node.js to continue."
    fi

    echo_with_color "33" "Found fnm. Attempting to initialize it..."
    initialize_fnm_for_session

    if ! command_exists npm; then
        echo_with_color "31" "npm could not be found after initializing fnm"

        if fnm install "${NODE_VERSION}"; then
            echo_with_color "32" "Node.js ${NODE_VERSION} installed successfully"
            initialize_fnm_for_session
            if fnm use "${NODE_VERSION}"; then
                echo_with_color "32" "Node.js ${NODE_VERSION} is now in use"
                confirm_node_and_npm
                install_npm_packages
            else
                exit_with_error "Failed to use Node.js ${NODE_VERSION}, please check fnm setup"
            fi
        else
            exit_with_error "Failed to install Node.js ${NODE_VERSION}, please check fnm setup"
        fi
    else
        echo_with_color "32" "npm found and working"
        confirm_node_and_npm
        install_npm_packages
    fi
else
    echo_with_color "32" "npm is already installed and working."
    confirm_node_and_npm
    install_npm_packages
fi