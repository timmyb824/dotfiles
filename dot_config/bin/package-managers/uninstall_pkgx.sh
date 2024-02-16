#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../init/init.sh"

# Function to uninstall a package
uninstall_package() {
    local package=$1
    echo_with_color "34" "Uninstalling ${package}..."
    if pkgx uninstall "${package}"; then
        echo_with_color "32" "${package} uninstalled successfully."
    else
        echo_with_color "31" "Failed to uninstall ${package}."
    fi
}

# Function to fetch and uninstall packages from a list
uninstall_packages_from_list() {
    local os_list=$1
    local package_list
    IFS=$'\n' read -r -d '' -a package_list < <(get_package_list "$os_list" && printf '\0')

    for package in "${package_list[@]}"; do
        uninstall_package "${package}"
    done
}

echo_with_color "34" "Starting the uninstallation process..."

# Uninstall all 'pkgx' packages first
uninstall_packages_from_list "pkgx"

echo_with_color "34" "Uninstallation process completed."