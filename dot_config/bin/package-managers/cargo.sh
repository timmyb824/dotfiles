#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../init/init.sh"


# Function to install cargo packages
install_cargo_packages() {
    echo_with_color "$CYAN_COLOR" "Installing cargo packages..."

    while IFS= read -r package; do
        trimmed_package=$(echo "$package" | xargs)  # Trim whitespace from the package name
        if [ -n "$trimmed_package" ]; then  # Ensure the line is not empty
            if cargo install "$trimmed_package"; then
                echo_with_color "$GREEN_COLOR" "Successfully installed $trimmed_package."
            else
                echo_with_color "$RED_COLOR" "Failed to install $trimmed_package."
            fi
        fi
    done < <(get_package_list cargo_mac.list)
}

# Function to initialize cargo
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
    fi
}

# Main execution
initialize_cargo
install_cargo_packages
