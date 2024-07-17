#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../init/init.sh"

# Function to prompt user for package list
prompt_for_package_list() {
    echo_with_color "$CYAN_COLOR" "Please select the package list you want to uninstall:"
    echo "1) pkgx_all.list"
    echo "2) pkgx_mac.list"
    echo "3) pkgx_linux.list"
    read -rp "Enter the number (1-3): " choice

    case $choice in
    1) package_list="pkgx_all.list" ;;
    2) package_list="pkgx_mac.list" ;;
    3) package_list="pkgx_linux.list" ;;
    *)
        echo_with_color "$RED_COLOR" "Invalid selection. Exiting."
        exit 1
        ;;
    esac
}

# Ensure pkgx is installed
if ! command_exists pkgx; then
    echo_with_color "$RED_COLOR" "pkgx could not be found"
    exit_with_error "pkgx is not installed."
fi

# Prompt user for the package list
prompt_for_package_list

# Fetch the selected package list
packages=($(get_package_list "$package_list"))

# Define binary paths
mc_bin_path="$HOME/.local/bin/mc"
mcomm_bin_path="$HOME/.local/bin/mcomm"

echo_with_color "$CYAN_COLOR" "Uninstalling packages..."

# Uninstall packages using pkgx
for package in "${packages[@]}"; do
    output=$(pkgx uninstall "${package}" 2>&1)

    if [[ "$output" == *"uninstalled"* ]]; then
        echo_with_color "$GREEN_COLOR" "${package} uninstalled successfully."
    elif [[ "$output" == "nothing provides:"* ]]; then
        echo_with_color "$RED_COLOR" "Error: Package ${package} is not a valid package."
        echo_with_color "$YELLOW_COLOR" "Continuing with the next package..."
    elif [[ "$output" == *"No such file or directory"* ]]; then
        echo_with_color "$RED_COLOR" "Error: An unexpected error occurred while trying to uninstall ${package}: $output"
        echo_with_color "$YELLOW_COLOR" "Continuing with the next package..."
        # echo "Error uninstalling ${package}: $output" >>uninstall_errors.log
    elif [[ -z "$output" ]]; then
        echo_with_color "$YELLOW_COLOR" "${package} was not installed."
    else
        echo_with_color "$RED_COLOR" "An unexpected error occurred while trying to uninstall ${package}: $output"
        echo_with_color "$YELLOW_COLOR" "Continuing with the next package..."
        # echo "Error uninstalling ${package}: $output" >> uninstall_errors.log
    fi
done

# Special handling for binaries after package uninstallation
if [[ -f "$mc_bin_path" ]]; then
    rm -f "$mc_bin_path" && echo_with_color "$BLUE_COLOR" "Removed mc binary"
fi

if [[ -f "$mcomm_bin_path" ]]; then
    rm -f "$mcomm_bin_path" && echo_with_color "$BLUE_COLOR" "Removed mcomm binary"
fi

echo_with_color "$CYAN_COLOR" "Uninstallation process completed."
