#!/bin/bash

source "$(dirname "$BASH_SOURCE")/init.sh"

# Function to install Homebrew on macOS
install_brew_macos() {
    if ! command_exists brew; then
        echo "Homebrew not found. Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        add_brew_to_path
    else
        echo "Homebrew is already installed."
    fi

    if ! command_exists brew; then
        exit_with_error "Homebrew installation failed or PATH setup was not successful."
    fi
}

# Function to optionally install Homebrew on Linux
install_brew_linux() {
    if ask_yes_or_no "Do you want to install Homebrew on Linux?"; then
        echo "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        add_brew_to_path
    else
        echo "Skipping Homebrew installation on Linux."
    fi

    if command_exists brew; then
        echo "Homebrew is installed."
    fi
}

# Prompt the user to install packages using Homebrew
install_packages_with_brew() {
    if ask_yes_or_no "Do you want to install the packages from the Brewfile?"; then
        brew bundle --file=Brewfile
    else
        echo "Skipping package installation."
    fi
}

# Function to update PATH for the current session
add_brew_to_path() {
    # Determine the system architecture for the correct Homebrew path
    local BREW_PREFIX
    if [[ "$(uname -m)" == "arm64" ]]; then
        BREW_PREFIX="/opt/homebrew/bin"
    else
        BREW_PREFIX="/usr/local/bin"
    fi

    # Construct the Homebrew path line
    local BREW_PATH_LINE="eval \"$(${BREW_PREFIX}/brew shellenv)\""

    # Check if Homebrew PATH is already in the PATH
    if ! echo "$PATH" | grep -q "${BREW_PREFIX}"; then
        echo "Adding Homebrew to PATH for the current session..."
        eval "${BREW_PATH_LINE}"
    fi
}

# Main execution
OS=$(get_os)
case $OS in
    "MacOS")
        install_brew_macos
        install_packages_with_brew
        ;;
    "Linux")
        if install_brew_linux; then
            install_packages_with_brew
        fi
        ;;
    *)
        exit_with_error "Unsupported operating system: $OS"
        ;;
esac

