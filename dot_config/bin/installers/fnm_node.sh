#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../init/init.sh"

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

# Function to initialize fnm for the current session
initialize_fnm_for_session() {
    # Initialize fnm without specifying a shell
    eval "$(fnm env --use-on-cd)"
}

install_for_macos() {
    # First, add the brew binary to the PATH if it's not already there
    add_brew_to_path

    # Check if npm is installed and working
    if ! command_exists npm; then
        echo_with_color "$RED_COLOR" "npm could not be found."

        # Attempt to fix fnm command availability
        attempt_fix_command fnm "$HOME/.local/bin"

        # Check for fnm again
        if command_exists fnm; then
            echo_with_color "$YELLOW_COLOR" "Found fnm, attempting to install Node.js ${NODE_VERSION}..."
            if fnm install "${NODE_VERSION}"; then
                echo_with_color "$GREEN_COLOR" "Node.js ${NODE_VERSION} installed successfully."

                # Initialize fnm for the current session
                initialize_fnm_for_session

                if fnm use "${NODE_VERSION}"; then
                    echo_with_color "$GREEN_COLOR" "Node.js ${NODE_VERSION} is now in use."
                else
                    exit_with_error "Failed to use Node.js ${NODE_VERSION}, please check fnm setup."
                fi
            else
                exit_with_error "Failed to install Node.js ${NODE_VERSION}, please check fnm setup."
            fi
        else
            exit_with_error "fnm is still not found after attempting to fix the PATH. Please install fnm to continue."
        fi
    else
        echo_with_color "$GREEN_COLOR" "npm is already installed and working."
    fi
}

install_for_linux() {
    # Check if npm is installed and working
    if ! command_exists npm; then
        echo_with_color "$RED_COLOR" "npm could not be found."

        # Attempt to fix fnm command availability
        initialize_cargo
        initialize_fnm_for_session

        # Check for fnm again
        if command_exists fnm; then
            echo_with_color "$YELLOW_COLOR" "Found fnm, attempting to install Node.js ${NODE_VERSION}..."
            if fnm install "${NODE_VERSION}"; then
                echo_with_color "$GREEN_COLOR" "Node.js ${NODE_VERSION} installed successfully."

                # Initialize fnm for the current session
                initialize_fnm_for_session

                if fnm use "${NODE_VERSION}"; then
                    echo_with_color "$GREEN_COLOR" "Node.js ${NODE_VERSION} is now in use."
                else
                    exit_with_error "Failed to use Node.js ${NODE_VERSION}, please check fnm setup."
                fi
            else
                exit_with_error "Failed to install Node.js ${NODE_VERSION}, please check fnm setup."
            fi
        else
            exit_with_error "fnm is still not found after attempting to fix the PATH. Please install fnm to continue."
        fi
    else
        echo_with_color "$GREEN_COLOR" "npm is already installed and working."
    fi
}

OS=$(get_os)

if [[ "$OS" == "MacOS" ]]; then
    install_for_macos
elif [[ "$OS" == "Linux" ]]; then
    install_for_linux
else
    exit_with_error "Unsupported operating system: $OS"
fi
