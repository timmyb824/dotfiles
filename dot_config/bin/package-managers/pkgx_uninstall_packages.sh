#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../init/init.sh"

# Function to prompt user for package list
prompt_for_package_list() {
    echo_with_color "$CYAN_COLOR" "Please select the package list you want to uninstall:"
    echo "1) pkgx_code_server.list"
    echo "2) pkgx_work.list"
    echo "3) pkgx_personal.list"
    echo "4) pkgx_linux_all.list"
    echo "5) pkgx_linux_init.list"
    echo "6) pkgx_linux.list"
    echo "7) pkgx_mac.list"
    read -p "Enter the number (1-7): " choice

    case $choice in
    1) package_list="pkgx_code_server.list" ;;
    2) package_list="pkgx_work.list" ;;
    3) package_list="pkgx_personal.list" ;;
    4) package_list="pkgx_linux_all.list" ;;
    5) package_list="pkgx_linux_init.list" ;;
    6) package_list="pkgx_linux.list" ;;
    7) package_list="pkgx_mac.list" ;;
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
    elif [[ -z "$output" ]]; then
        echo_with_color "$YELLOW_COLOR" "${package} was not installed."
    else
        # Log the error but do not exit the script
        echo_with_color "$RED_COLOR" "An unexpected error occurred while trying to uninstall ${package}: $output"
        # Optionally, you can write the error to a log file
        # echo "Error uninstalling ${package}: $output" >> uninstall_errors.log
        # Continue with the next iteration
        echo_with_color "$YELLOW_COLOR" "Continuing with the next package..."
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
