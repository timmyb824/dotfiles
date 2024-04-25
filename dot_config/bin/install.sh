#!/usr/bin/env bash

# Exit on any error
set -e

# Source common functions with a check
INIT_SCRIPT_PATH="$(dirname "$BASH_SOURCE")/init/init.sh"
if [[ -f "$INIT_SCRIPT_PATH" ]]; then
    source "$INIT_SCRIPT_PATH"
else
    exit_with_error "Unable to source init.sh, file not found."
fi

# Function to make a script executable and run it
change_and_run_script() {
    local script="$1"
    if ask_yes_or_no "Do you want to run $script?"; then
        echo_with_color "$GREEN_COLOR" "Running $script..."
        chmod +x "$script"  # Make the script executable
        "$script"           # Execute the script
        echo_with_color "$GREEN_COLOR" "$script completed."
    else
        echo_with_color "$YELLOW_COLOR" "Skipping $script..."
    fi
}

# Main installation process
echo_with_color "$GREEN_COLOR" "Starting package installations for macOS..."

SCRIPT_DIR="dot_config/bin"

# An array of scripts to run, for cleaner management and scalability
declare -a scripts_to_run=(
    "package-managers/homebrew.sh"
    "package-managers/pkgx.sh"
    "package-managers/basher.sh"
    "installers/kubectl_krew.sh"
    "package-managers/krew.sh"
    "package-managers/micro.sh"
    "installers/pyenv_python.sh"
    "package-managers/pip.sh"
    "package-managers/pipx.sh"
    "installers/fnm_node.sh"
    "package-managers/npm.sh"
    "installers/tfenv_terraform.sh"
    "installers/tailscale.sh"
    "installers/rbenv_ruby.sh"
    "installers/rust.sh
    "installers/atuin.sh"
    "configuration/go_directories.sh"
)

# Iterate through the scripts and run them
for script in "${scripts_to_run[@]}"; do
    change_and_run_script "$SCRIPT_DIR/$script"
done

echo_with_color "$GREEN_COLOR" "All macOS packages have been installed."