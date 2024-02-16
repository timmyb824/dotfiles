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
        echo_with_color "32" "basher installed successfully"
    else
        exit_with_error "Failed to install basher"
    fi
else
    echo_with_color "34" "basher is already installed at $HOME/.basher"
fi

basher_bin="$HOME/.basher/bin"

# Check if basher's bin directory is in the PATH
add_to_path_exact_match "$basher_bin"

# Get the list of packages from the gist and iterate over them
while IFS= read -r package; do
    if [ -n "$package" ]; then  # Ensure the line is not empty
        if basher install "$package"; then
            echo_with_color "32" "${package} installed successfully"
        else
            exit_with_error "Failed to install ${package}"
        fi
    fi
done < <(get_package_list basher)

echo_with_color "32" "basher.sh completed successfully."