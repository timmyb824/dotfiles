#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../init/init.sh"

# Used for the Linux scripts, leaving this here for reference
# initialize_atuin() {
#     echo_with_color "$YELLOW_COLOR" "Initializing atuin..."
#     eval "$(atuin init bash)"
# }

# Function to initialize atuin for zsh
initialize_atuin() {
    local shell_name
    shell_name=$(basename "$SHELL")

    if [ -z "$shell_name" ]; then
        echo_with_color "$RED_COLOR" "Unable to determine the shell for atuin initialization."
        exit_with_error "Shell not found for atuin initialization." 1
    else
        echo_with_color "$YELLOW_COLOR" "Initializing atuin for $shell_name..."
        eval "$(atuin init "$shell_name")"
    fi
}

login_to_atuin() {
    if atuin status &>/dev/null; then
        if atuin status | grep -q "cannot show sync status"; then
            echo_with_color "$YELLOW_COLOR" "atuin is not logged in."
            if atuin login -u "$ATUIN_USER"; then
                echo_with_color "$GREEN_COLOR" "atuin login successful."
            else
                echo_with_color "$RED_COLOR" "atuin login failed."
                exit_with_error "Failed to log in to atuin with user $ATUIN_USER." 2
            fi
        else
            echo_with_color "$GREEN_COLOR" "atuin is already logged in."
        fi
    else
        echo_with_color "$RED_COLOR" "Unable to determine atuin status. Please check atuin configuration."
        exit_with_error "Unable to determine atuin status." 1
    fi
}

initialize_cargo() {
    if command_exists cargo; then
        echo_with_color "$GREEN_COLOR" "cargo is already installed."
    else
        echo_with_color "$YELLOW_COLOR" "Initializing cargo..."
        if [ -f "$HOME/.cargo/env" ]; then
            source "$HOME/.cargo/env"
        else
            echo_with_color "$RED_COLOR" "Cargo environment file does not exist."
            exit_with_error "Please install cargo to continue." 1
        fi

        if ! command_exists cargo; then
            echo_with_color "$RED_COLOR" "Cargo is still not found after attempting to fix the PATH."
            exit_with_error "Please install cargo to continue." 1
        fi
    fi
}

install_atuin_with_cargo() {
    initialize_cargo
    echo_with_color "$YELLOW_COLOR" "Installing atuin with cargo..."
    if cargo install atuin; then
        echo_with_color "$GREEN_COLOR" "atuin installed successfully."
        initialize_atuin
        login_to_atuin
    else
        echo_with_color "$RED_COLOR" "Failed to install atuin."
        exit_with_error "Failed to install atuin with cargo." 1
    fi
}

install_atuin_with_script() {
    echo_with_color "$YELLOW_COLOR" "Installing atuin with the atuin script..."
    if bash <(curl -sS https://raw.githubusercontent.com/ellie/atuin/main/install.sh); then
        echo_with_color "$GREEN_COLOR" "atuin installed successfully."
        initialize_atuin
        login_to_atuin
    else
        echo_with_color "$RED_COLOR" "Failed to install atuin."
        exit_with_error "Failed to install atuin with the script." 1
    fi
}

atuin_for_macos() {
    # Ensure brew is in the PATH
    add_brew_to_path

    if command_exists atuin; then
        echo_with_color "$GREEN_COLOR" "atuin is already installed."
        echo_with_color "$YELLOW_COLOR" "Checking atuin status..."
        login_to_atuin
    else
        echo_with_color "$RED_COLOR" "atuin could not be found."
        echo_with_color "$YELLOW_COLOR" "Installing atuin..."
        brew install atuin
        initialize_atuin
        echo_with_color "$GREEN_COLOR" "atuin installed successfully."
        login_to_atuin
    fi
}

atuin_for_linux() {
    read -rp "Do you want to install atuin with cargo or the official script? [cargo/script]: " choice

    case $choice in
    cargo)
        install_atuin_with_cargo
        ;;
    script)
        install_atuin_with_script
        ;;
    *)
        echo_with_color "$RED_COLOR" "Invalid choice. Please select 'cargo' or 'script'."
        exit_with_error "Invalid choice." 1
        ;;
    esac
}

if [[ "$OS" == "MacOS" ]]; then
    atuin_for_macos
elif [[ "$OS" == "Linux" ]]; then
    atuin_for_linux
else
    exit_with_error "Unsupported operating system: $OS"
fi
