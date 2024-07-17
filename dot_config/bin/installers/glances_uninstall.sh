#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../init/init.sh"

USER="$CURRENT_USER"
PYENV_BIN="/home/${USER}/.pyenv/bin/pyenv"
SERVICE_FILE="/etc/systemd/system/glances.service"

initialize_pyenv() {
    # Initialize pyenv for the current session
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init --path)"
    eval "$(pyenv init -)"
}

remove_glances_service() {
    echo_with_color "$GREEN_COLOR" "Disabling and removing glances systemd service..."
    if sudo systemctl is-active --quiet glances; then
        sudo systemctl stop glances || echo_with_color "$RED_COLOR" "Failed to stop glances service."
    fi
    if sudo systemctl is-enabled --quiet glances; then
        sudo systemctl disable glances || echo_with_color "$RED_COLOR" "Failed to disable glances service."
    fi
    if [ -f "$SERVICE_FILE" ]; then
        sudo rm -f "$SERVICE_FILE" || echo_with_color "$RED_COLOR" "Failed to remove glances service file."
        sudo systemctl daemon-reload || echo_with_color "$RED_COLOR" "Failed to reload systemd daemon."
    fi
}

remove_virtualenv() {
    echo_with_color "$GREEN_COLOR" "Removing glances virtualenv..."
    if ! command_exists pyenv; then
        echo_with_color "$YELLOW_COLOR" "pyenv command not found. Attempting to initialize pyenv..."
        initialize_pyenv || echo_with_color "$RED_COLOR" "Failed to initialize pyenv."
        if ! command_exists pyenv; then
            echo_with_color "$RED_COLOR" "pyenv command still not found. Please make sure it is installed."
            return
        fi
    fi

    if $PYENV_BIN versions --bare | grep -q "^glances\$"; then
        $PYENV_BIN uninstall -f glances || echo_with_color "$RED_COLOR" "Failed to uninstall glances virtual environment."
    fi
}

remove_directories() {
    echo_with_color "$GREEN_COLOR" "Removing directories..."
    for dir in "/home/${USER}/.config/glances" "/home/${USER}/glances"; do
        if [ -d "$dir" ]; then
            rm -rf "$dir" || echo_with_color "$RED_COLOR" "Failed to remove directory: $dir"
        fi
    done
}

main() {
    remove_glances_service
    remove_virtualenv
    remove_directories
}

main