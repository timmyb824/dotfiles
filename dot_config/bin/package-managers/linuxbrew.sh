#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../init/init.sh"

# Function to remove commands that were installed outside of Homebrew using apt but are now managed by Homebrew
safe_remove_command_apt() {
    local command_name="$1"

    if command_exists "$command_name"; then
        echo_with_color "$YELLOW_COLOR" "Removing $command_name..."
        sudo apt remove --purge -y "$command_name" || exit_with_error "Failed to remove $command_name."
    else
        echo_with_color "$GREEN_COLOR" "$command_name is not installed."
    fi
}

# Function to install Homebrew on macOS
install_brew_linux() {
    if ! command_exists brew; then
        echo_with_color "$BLUE_COLOR" "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || exit_with_error "Homebrew installation failed."
        add_brew_to_path
    else
        echo_with_color "$GREEN_COLOR" "Homebrew is already installed."
    fi

    # Verify if Homebrew installation was successful and available
    command_exists brew || exit_with_error "Homebrew installation failed or PATH setup was not successful."
}

install_packages_with_brew() {
    local temp_brewfile=$(mktemp)

    if ask_yes_or_no "Do you want to install the packages from the Brewfile?"; then
        # Fetching the Brewfile content and writing to temporary file
        get_package_list Brewfile > "$temp_brewfile" || exit_with_error "Failed to fetch Brewfile."

        # Ensure that the temporary Brewfile has content before proceeding
        if [ -s "$temp_brewfile" ]; then
            echo_with_color "$BLUE_COLOR" "Installing packages from the Brewfile..."
            output=$(brew bundle --file="$temp_brewfile" 2>&1)
            echo "$output"
            if echo "$output" | grep -q "failed"; then
                echo_with_color "$RED_COLOR" "Failed to install packages from the Brewfile."
            else
                echo_with_color "$GREEN_COLOR" "Packages installed successfully."
            fi

        else
            exit_with_error "The fetched Brewfile is empty."
        fi
    else
        echo_with_color "$YELLOW_COLOR" "Skipping package installation."
    fi

    # Cleanup: Remove the temporary Brewfile regardless of earlier actions
    rm "$temp_brewfile" || echo_with_color "$YELLOW_COLOR" "Warning: Failed to remove temporary Brewfile."
}

# Function to add Homebrew to PATH if it's not already there
add_brew_to_path

# Remove commands that were installed outside of Homebrew but are now managed by Homebrew
safe_remove_command_apt "1password-cli"

install_brew_linux
install_packages_with_brew
