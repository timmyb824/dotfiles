#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../init/init.sh"

# Function to uninstall individual binaries
uninstall_binary() {
    local bin_path="$1"
    if [[ -f "$bin_path" ]]; then
        sudo rm -f "$bin_path" && echo_with_color "$BLUE_COLOR" "Removed $(basename "$bin_path") binary"
    fi
}

# Function to prompt user for package list
prompt_for_package_list() {
    echo_with_color "$CYAN_COLOR" "Please select the package list you want to uninstall:"
    echo "1) pkgx_code_server.list"
    echo "2) pkgx_work.list"
    echo "3) pkgx_personal.list"
    echo "4) pkgx_linux.list"
    read -p "Enter the number (1-4): " choice

    case $choice in
    1) package_list="pkgx_code_server.list" ;;
    2) package_list="pkgx_work.list" ;;
    3) package_list="pkgx_personal.list" ;;
    4) package_list="pkgx_linux.list" ;;
    *)
        echo_with_color "$RED_COLOR" "Invalid selection. Exiting."
        exit 1
        ;;
    esac
}

# Function to uninstall pkgx either the binary or via homebrew
uninstall_pkgx() {
    if command_exists pkgx; then
        echo_with_color $BLUE_COLOR "Uninstalling pkgx..."
        if command_exists brew; then
            brew uninstall pkgxdev/made/pkgx || exit_with_error "Uninstallation of pkgx using Homebrew failed."
        else
            sudo rm -f "$(command -v pkgx)" || exit_with_error "Uninstallation of pkgx failed."
        fi
    else
        echo_with_color $GREEN_COLOR "pkgx is not installed."
    fi
}

uninstall_pkgx_directories() {
    echo_with_color "$BLUE_COLOR" "Uninstalling .pkgx directories..."

    # Define the directories to remove
    local directories_to_remove=(
        "$HOME/.pkgx"
        "${XDG_CACHE_HOME:-$HOME/Library/Caches}/pkgx"
        "${XDG_DATA_HOME:-$HOME/Library/Application Support}"/pkgx
    )

    # Loop through each directory and remove if it exists
    for dir in "${directories_to_remove[@]}"; do
        if [[ -d "$dir" ]]; then
            echo_with_color "$RED_COLOR" "Removing directory: $dir"
            rm -rf "$dir" || exit_with_error "Uninstallation of directory $dir failed."
        else
            echo_with_color "$GREEN_COLOR" "Directory does not exist: $dir"
        fi
    done
}

# Special handling for binaries after package uninstallation
# List of binaries to check and potentially remove
binary_paths=(
    "$HOME/.local/bin/mc"
    "$HOME/.local/bin/mcomm"
)

if ! command_exists pkgx; then
    echo_with_color "$RED_COLOR" "pkgx could not be found"
    exit_with_error "pkgx is not installed."
fi


# Prompt user for the package list
prompt_for_package_list

# Fetch the selected package list
# Temporarily change IFS to read lines properly if they contain spaces
OLD_IFS="$IFS"
IFS=$'\n'
packages=($(get_package_list "$package_list"))
IFS="$OLD_IFS"

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
        # This is the new case we are adding
        echo_with_color "$RED_COLOR" "Error: An unexpected error occurred while trying to uninstall ${package}: $output"
        echo_with_color "$YELLOW_COLOR" "Continuing with the next package..."
        # Optionally, you can write the error to a log file
        echo "Error uninstalling ${package}: $output" >> uninstall_errors.log
    elif [[ -z "$output" ]]; then
        echo_with_color "$YELLOW_COLOR" "${package} was not installed."
    else
        # This case is for other unexpected errors
        echo_with_color "$RED_COLOR" "An unexpected error occurred while trying to uninstall ${package}: $output"
        echo_with_color "$YELLOW_COLOR" "Continuing with the next package..."
        # Optionally, you can write the error to a log file
        echo "Error uninstalling ${package}: $output" >> uninstall_errors.log
    fi
done

for bin_path in "${binary_paths[@]}"; do
    uninstall_binary "$bin_path"
done

uninstall_pkgx
uninstall_pkgx_directories

echo_with_color "$CYAN_COLOR" "Uninstallation process completed."