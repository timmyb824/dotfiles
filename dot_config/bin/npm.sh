#!/bin/bash

# Function to update shell configuration with fnm initialization
add_fnm_to_shell() {
    local SHELL_CONFIG

    if [[ -f "$HOME/.bashrc" ]]; then
        SHELL_CONFIG="$HOME/.bashrc"
    elif [[ -f "$HOME/.zshrc" ]]; then
        SHELL_CONFIG="$HOME/.zshrc"
    else
        echo "Could not find a shell configuration file to update with fnm initialization."
        exit 1
    fi

    # Add fnm to the shell config if not already present
    if ! grep -q 'fnm env' "$SHELL_CONFIG"; then
        # Appends the fnm env command to the shell config
        echo 'eval "$(fnm env --use-on-cd)"' >> "$SHELL_CONFIG"
        # Source the shell configuration to update the current session
        eval "$(fnm env --use-on-cd)"
    fi
}

# Check if npm is installed
if ! command -v npm &> /dev/null; then
    echo "npm could not be found"

    # Check for fnm
    if command -v fnm &> /dev/null; then
        echo "Found fnm, attempting to install Node.js v21.0.0..."
        if fnm install v21.0.0; then
            echo "Node.js v21.0.0 installed successfully"

            # Initialize fnm in the shell config
            add_fnm_to_shell

            if fnm use v21.0.0; then
                echo "Node.js v21.0.0 is now in use"
            else
                echo "Failed to use Node.js v21.0.0, please check fnm setup"
                exit 1
            fi
        else
            echo "Failed to install Node.js v21.0.0, please check fnm setup"
            exit 1
        fi
    else
        echo "npm and fnm not found. Please install Node.js to continue."
        exit 1
    fi
fi

# Re-check if npm is installed after potentially installing Node.js with fnm
if ! command -v npm &> /dev/null; then
    echo "npm is still not found after attempting Node.js installation with fnm"
    exit 1
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
)

echo "Installing npm global packages..."

# Iterate over the packages and install one by one
for package in "${packages[@]}"; do
    if npm install -g "${package}"; then
        echo "${package} installed successfully"
    else
        echo "Failed to install ${package}"
    fi
done

echo "All npm global packages installation attempted."
