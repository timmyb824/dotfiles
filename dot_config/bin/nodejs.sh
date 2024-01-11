#!/bin/bash

# Source the common functions script
source "$(dirname "$BASH_SOURCE")/init.sh"

# Set the desired Node.js version
NODE_VERSION="v21.0.0"

# Function to initialize fnm for the current session
initialize_fnm_for_session() {
    # Specify the shell directly if fnm can't infer it
    local SHELL_NAME="zsh"
    eval "$(fnm env --use-on-cd --shell=${SHELL_NAME})"
}

# Check if npm is installed and working
if ! command_exists npm; then
    echo_with_color "31" "npm could not be found"

    # Check for fnm
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
        echo_with_color "31" "npm and fnm not found. Please install Node.js to continue."
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