#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../init/init.sh"

OS=$(get_os)

install_cargo_packages_linux() {
    echo_with_color "$CYAN_COLOR" "Installing cargo packages..."

    while IFS= read -r package; do
        trimmed_package=$(echo "$package" | xargs)  # Trim whitespace from the package name
        if [ -n "$trimmed_package" ]; then  # Ensure the line is not empty
            output=$(cargo install "$trimmed_package")
            echo "$output"
            if [[ "$trimmed_package" == "zellij" ]]; then
                if ! command_exists zellij; then
                    echo_with_color "$RED_COLOR" "Failed to install zellij with cargo, trying pkgx..."
                    if ! pkgx install zellij; then
                        echo_with_color "$RED_COLOR" "Failed to install zellij with pkgx."
                    else
                        echo_with_color "$GREEN_COLOR" "zellij installed successfully with pkgx."
                    fi
                else
                    echo_with_color "$GREEN_COLOR" "zellij installed successfully with cargo."
                fi
                echo_with_color "$YELLOW_COLOR" "Continuing with the next package..."
            elif [[ "$output" == *"error"* ]]; then
                echo_with_color "$RED_COLOR" "Failed to install ${trimmed_package}."
                echo_with_color "$YELLOW_COLOR" "Continuing with the next package..."
            else
                echo_with_color "$GREEN_COLOR" "${trimmed_package} installed successfully."
            fi
        fi
    done < <(get_package_list cargo_linux.list)
}

install_cargo_packages_macos() {
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

initialize_cargo

if [[ "$OS" == "MacOS" ]]; then
    install_cargo_packages_macos
elif [[ "$OS" == "Linux" ]]; then
    install_cargo_packages_linux
else
    exit_with_error "Unsupported operating system: $OS"
fi
