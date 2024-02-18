#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../init/init.sh"

# Check if git is installed
if ! command_exists git; then
    exit_with_error "git is not installed - please install git and run this script again"
fi

# Check if basher is not already installed
if [ ! -d "$HOME/.basher" ]; then
    echo "basher is not installed. Installing now..."
    if git clone --depth=1 https://github.com/basherpm/basher.git ~/.basher; then
        echo_with_color "$GREEN_COLOR" "basher installed successfully"
    else
        exit_with_error "Failed to install basher"
    fi
else
    echo_with_color "$BLUE_COLOR" "basher is already installed at $HOME/.basher"
fi

basher_bin="$HOME/.basher/bin"

# Ensure basher's bin directory is in the PATH
add_to_path_exact_match "$basher_bin"

# Function to install a package with basher
install_package_with_basher() {
    local package=$1
    if basher install "$package"; then
        echo_with_color "$GREEN_COLOR" "${package} installed successfully"
    else
        exit_with_error "Failed to install ${package}"
    fi
}

# Get the list of packages from the gist
package_list=$(get_package_list basher)

# Check if the package list is retrieved successfully
if [ -z "$package_list" ]; then
    exit_with_error "Failed to retrieve the package list."
fi

# Iterate over the package list and install packages
while IFS= read -r package; do
    if [ -n "$package" ]; then  # Ensure the line is not empty
        install_package_with_basher "$package"
    fi
done <<< "$package_list"
