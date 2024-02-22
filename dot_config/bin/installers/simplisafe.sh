#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../init/init.sh"

install_ss_brew() {
    echo_with_color "$GREEN_COLOR" "Install SimpliSafe brew packages..."
    if ! command_exists brew; then
        exit_with_error "Homebrew could not be found. Please install Homebrew to continue."
    fi

    brew tap simplisafe/simplisafe-tools git+ssh://git@github.com/simplisafe/homebrew-simplisafe-tools.git
    brew install saml2aws
    brew install meetingbar
}

# Function to download and install 1Password CLI on macOS
install_dex() {
    if command_exists dx; then
        echo_with_color "$YELLOW_COLOR" "dx is already installed."
        return 0 # Indicate that it's already installed
    fi

    echo_with_color "$GREEN_COLOR" "Installing the dx for macOS..."

    # Check for required download commands
    if ! command_exists curl; then
        echo_with_color "$RED_COLOR" "Error: 'curl' is required to download files."
        return 1
    fi

    if command_exists curl; then
        sudo curl --fail https://artifactory.tools.simplisafe.com/artifactory/devops-generic/dx/latest -o /usr/local/bin/dx && sudo chmod +x /usr/local/bin/dx
    fi

    # Verify the installation
    if command_exists dx; then
        echo_with_color "$GREEN_COLOR" "dx was installed successfully."
        echo_with_color "$GREEN_COLOR" "Please run 'dx install-completion' and restart your terminal."
    else
        echo_with_color "$RED_COLOR" "Error: The dx installation failed."
        return 1
    fi
}

install_awashcli() {
    if command_exists awashcli; then
        echo_with_color "$YELLOW_COLOR" "awashcli is already installed."
        return 0 # Indicate that it's already installed
    fi

    echo_with_color "$GREEN_COLOR" "Installing the awashcli for macOS..."

    # Check for required download commands
    if ! command_exists curl; then
        echo_with_color "$RED_COLOR" "Error: 'curl' is required to download files."
        return 1
    fi

    if command_exists curl; then
        source <(curl -s --fail -L https://artifactory.tools.simplisafe.com/artifactory/devops-generic/awash/install.sh)
    fi

    # Verify the installation
    if command_exists awashcli; then
        echo_with_color "$GREEN_COLOR" "awashcli was installed successfully."
        echo_with_color "$GREEN_COLOR" "Please run 'awashcli setup <team> zsh' and restart your terminal."
    else
        echo_with_color "$RED_COLOR" "Error: The awashcli installation failed."
        return 1
    fi
}

if ask_yes_or_no "PLEASE CONFIRM YOU ARE ON THE VPN ELSE THIS SCRIPT WILL FAIL"; then
    add_brew_to_path
    install_ss_brew
    install_dex
    install_awashcli
    echo_with_color "$GREEN_COLOR" "SimpliSafe installations complete."
else
    exit_with_error "Please connect to the VPN and run the script again."
fi
