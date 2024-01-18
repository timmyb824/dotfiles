#!/usr/bin/env bash

# Source the common functions script
source "$(dirname "$BASH_SOURCE")/../utilities/init.sh"

# Function to initialize fnm for the current session
initialize_fnm_for_session() {
    # Initialize fnm without specifying a shell
    eval "$(fnm env --use-on-cd)"
}

# Function to add a directory to PATH
add_to_path() {
    PATH="$1:$PATH"
    export PATH
}

# Check if npm is installed and working
if ! command_exists npm; then
    echo_with_color "31" "npm could not be found"

    # Attempt to fix fnm command availability
    attempt_fix_command fnm "$HOME/.local/bin"

    # Check for fnm again
    if command_exists fnm; then
        echo_with_color "33" "Found fnm, attempting to install Node.js ${NODE_VERSION}..."
        if fnm install "${NODE_VERSION}"; then
            echo_with_color "32" "Node.js ${NODE_VERSION} installed successfully"

            # Initialize fnm for the current session
            initialize_fnm_for_session

            if fnm use "${NODE_VERSION}"; then
                echo_with_color "32" "Node.js ${NODE_VERSION} is now in use"
            else
                echo_with_color "31" "Failed to use Node.js ${NODE_VERSION}, please check fnm setup"
                exit 1
            fi
        else
            echo_with_color "31" "Failed to install Node.js ${NODE_VERSION}, please check fnm setup"
            exit 1
        fi
    else
        echo_with_color "31" "fnm is still not found after attempting to fix the PATH. Please install Node.js to continue."
        exit 1
    fi
else
    echo_with_color "32" "npm is already installed and working."
fi

# List of packages to install
packages=(
    "aicommits"
    "awsp"
    "neovim"
    "opencommit"
    "pm2"
    "kubelive"
    "gtop"
    "lineselect"
    # commenting out inshellisense for now (not working properly yet)
    # "node-gyp" # dependency of inshellisense
    # "@microsoft/inshellisense"
)

echo_with_color "36" "Installing npm global packages..."

# Iterate over the packages and install one by one
for package in "${packages[@]}"; do
    if npm install -g "${package}"; then
        echo_with_color "32" "${package} installed successfully"
    else
        echo_with_color "31" "Failed to install ${package}"
        exit 1
    fi
done

echo_with_color "32" "nodejs.sh completed successfully"