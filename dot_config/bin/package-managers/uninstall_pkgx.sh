#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../init/init.sh"

# Define the array of packages that are common to both environments
common_packages=( $(get_package_list pkgx) )

# Define the array of additional packages for your personal computer
personal_packages=( $(get_package_list pkgx_personal) )

# Fetch the list of packages to uninstall based on the hostname
hostname=$(hostname)
if [[ "$hostname" == "$WORK_HOSTNAME" ]]; then
    echo_with_color "$CYAN_COLOR" "Uninstalling packages for work environment..."
    packages_to_uninstall=( "${common_packages[@]}" )
else
    echo_with_color "$CYAN_COLOR" "Uninstalling packages for personal environment..."
    packages_to_uninstall=( "${personal_packages[@]}" "${common_packages[@]}" )
fi

# Function to uninstall a package
uninstall_package() {
    local package=$1
    echo_with_color $BLUE_COLOR "Uninstalling ${package}..."
    if pkgx uninstall "${package}"; then
        echo_with_color $GREEN_COLOR "${package} uninstalled successfully."
    else
        echo_with_color $RED_COLOR "Failed to uninstall ${package}."
    fi
}

# Function to uninstall pkgx either the binary or via homebrew
uninstall_pkgx() {
    if command_exists pkgx; then
        echo_with_color $BLUE_COLOR "Uninstalling pkgx..."
        if command_exists brew; then
            brew uninstall pkgxdev/made/pkgx || echo_with_color $RED_COLOR "Uninstallation of pkgx using Homebrew failed."
        else
            sudo rm -f "$(command -v pkgx)" || echo_with_color $RED_COLOR "Uninstallation of pkgx failed."
        fi
    else
        echo_with_color $GREEN_COLOR "pkgx is not installed."
    fi
}

# Function to uninstall .pkgx directory
uninstall_pkgx_directory() {
    echo_with_color $BLUE_COLOR "Uninstalling .pkgx directory..."
    rm -rf "$HOME/.pkgx" || echo_with_color $RED_COLOR "error: Uninstallation of .pkgx directory failed."
}

uninstall_pkgx_cache() {
    echo_with_color $BLUE_COLOR "Uninstalling pkgx cache..."
    sudo rm -rf "${XDG_CACHE_HOME:-$HOME/Library/Caches}/pkgx" || echo_with_color $RED_COLOR "error: Uninstallation of pkgx cache failed."
    sudo rm -rf "${XDG_DATA_HOME:-$HOME/Library/Application Support}"/pkgx || echo_with_color $RED_COLOR "error: Uninstallation of pkgx cache failed."
}

remove_special_pkgx_files() {
    echo_with_color $BLUE_COLOR "Removing special pkgx files..."
    rm -f $HOME/.local/bin/mcomm || echo_with_color $RED_COLOR "error: Uninstallation of mcomm failed."
}

echo_with_color $BLUE_COLOR "Starting the uninstallation process..."

# Uninstall packages based on the list
for package in "${packages_to_uninstall[@]}"; do
    uninstall_package "${package}"
done

uninstall_pkgx
uninstall_pkgx_directory
uninstall_pkgx_cache
remove_special_pkgx_files

echo_with_color $BLUE_COLOR "Uninstallation process completed."