#!/bin/bash

# Function to check if a given line is in a file
line_in_file() {
    local line="$1"
    local file="$2"
    grep -Fq -- "$line" "$file"
}

# Function to add krew to PATH if it's not already in the PATH
add_krew_to_path() {
    local krew_path_export='export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"'
    local profile_file="$HOME/.zshrc"  # or change to .zshrc or .profile depending on shell and preference

    if ! line_in_file "$krew_path_export" "$profile_file"; then
        echo "Adding krew to PATH in $profile_file"
        echo "$krew_path_export" >> "$profile_file"
        # Source the profile file to update the current session
        source "$profile_file"
    elif ! command -v kubectl-krew &> /dev/null; then
        # The line exists in the file, but krew is not in the PATH of the current session
        source "$profile_file"
    fi
}

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo "kubectl could not be found"
    exit 1
fi

# Add krew to PATH if not already there
add_krew_to_path

# Check if krew is installed
if ! kubectl krew &> /dev/null; then
    echo "krew could not be found"
    exit 1
fi

# List of plugins to install
plugins=(
    "ctx"
    "ns"
)

# Iterate over the plugins and install one by one
for plugin in "${plugins[@]}"; do
    if ! kubectl krew list | grep -q "$plugin"; then
        if kubectl krew install "$plugin"; then
            echo "$plugin installed successfully"
        else
            echo "Failed to install $plugin"
        fi
    else
        echo "$plugin is already installed"
    fi
done
