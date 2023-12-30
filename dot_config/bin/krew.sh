#!/bin/bash

# Function to add krew to PATH for the current session if it's not already in the PATH
add_krew_to_path_for_session() {
    local krew_path="${KREW_ROOT:-$HOME/.krew}/bin"
    if ! echo "$PATH" | grep -q "$krew_path"; then
        echo "Adding krew to PATH for the current session"
        export PATH="$krew_path:$PATH"
    fi
}

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo "kubectl could not be found"
    exit 1
fi

# Check if krew is installed and working
if ! kubectl krew &> /dev/null; then
    echo "krew could not be found or is not working properly, attempting to add to PATH for the current session"
    add_krew_to_path_for_session
    # Re-check if kubectl krew works after adding to PATH
    if ! kubectl krew &> /dev/null; then
        echo "krew is still not working after attempting to add to PATH"
        exit 1
    fi
fi

# List of plugins to install
plugins=(
    "ctx"
    "ns"
)

# Iterate over the plugins and install one by one
for plugin in "${plugins[@]}"; do
    if ! kubectl krew list | grep -q "$plugin"; then
        echo "Installing $plugin..."
        if kubectl krew install "$plugin"; then
            echo "$plugin installed successfully"
        else
            echo "Failed to install $plugin"
            exit 1
        fi
    else
        echo "$plugin is already installed"
    fi
done

# If the script reaches this point, all plugins have been installed successfully
echo "All specified krew plugins have been installed."
