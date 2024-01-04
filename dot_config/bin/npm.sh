#!/bin/bash

# Set the desired Node.js version
NODE_VERSION="v21.0.0"

# Function to initialize fnm for the current session
initialize_fnm_for_session() {
    eval "$(fnm env --use-on-cd)"
}

# Check if npm is installed and working
if ! command -v npm &> /dev/null; then
    echo "npm could not be found"

    # Check for fnm
    if command -v fnm &> /dev/null; then
        echo "Found fnm, attempting to install Node.js ${NODE_VERSION}..."
        if fnm install "${NODE_VERSION}"; then
            echo "Node.js ${NODE_VERSION} installed successfully"

            # Initialize fnm for the current session
            initialize_fnm_for_session

            if fnm use "${NODE_VERSION}"; then
                echo "Node.js ${NODE_VERSION} is now in use"
            else
                echo "Failed to use Node.js ${NODE_VERSION}, please check fnm setup"
                exit 1
            fi
        else
            echo "Failed to install Node.js ${NODE_VERSION}, please check fnm setup"
            exit 1
        fi
    else
        echo "npm and fnm not found. Please install Node.js to continue."
        exit 1
    fi
else
    echo "npm is already installed and working."
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
    # "node-gyp" # dependacy of inshellisense
    # "@microsoft/inshellisense"
)

echo "Installing npm global packages..."

# Iterate over the packages and install one by one
for package in "${packages[@]}"; do
    if npm install -g "${package}"; then
        echo "${package} installed successfully"
    else
        echo "Failed to install ${package}"
        exit 1
    fi
done

echo "All npm global packages installation attempted."
