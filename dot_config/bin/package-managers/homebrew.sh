#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../init/init.sh"

# Function to install Homebrew on macOS
install_brew_macos() {
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

        # Check if the temporary Brewfile is empty
        if [ ! -s "$temp_brewfile" ]; then
            exit_with_error "The fetched Brewfile is empty."
        fi

        # Ensure that the temporary Brewfile has content before proceeding
        if [ -s "$temp_brewfile" ]; then
            echo_with_color "$BLUE_COLOR" "Installing packages from the Brewfile..."
            brew bundle --file="$temp_brewfile"
            if [ $? -ne 0 ]; then
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

install_special_applications() {
    if ! command_exists mas; then
        msg_warn "mas is not installed. Skipping installation of Mac App Store apps."
        return
    fi

    if ask_yes_or_no "Do you want to install Slack?"; then
        if mas install 803453959; then
            msg_ok "Slack installed successfully."
        else
            msg_error "Failed to install Slack."
        fi
    fi
}

# Function to add Homebrew to PATH if it's not already there
add_brew_to_path

# Remove commands that were installed outside of Homebrew but are now managed by Homebrew
safe_remove_command "/usr/local/bin/op"

install_brew_macos
install_packages_with_brew
install_special_applications
