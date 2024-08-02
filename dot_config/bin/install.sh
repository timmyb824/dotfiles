#!/usr/bin/env bash

set -e

OS=$(get_os)
SCRIPT_DIR="dot_config/bin"


INIT_SCRIPT_PATH="$(dirname "$BASH_SOURCE")/init/init.sh"
if [[ -f "$INIT_SCRIPT_PATH" ]]; then
    source "$INIT_SCRIPT_PATH"
else
    exit_with_error "Unable to source init.sh, file not found."
fi

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

install_macos_packages() {
    echo_with_color "$GREEN_COLOR" "Starting package installations for macOS..."

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
        "package-managers/gem.sh"
        "installers/rust.sh"
        "installers/cargo.sh"
        "installers/atuin.sh"
        "configuration/go_directories.sh"
        "package-managers/gh_cli.sh"
        "configuration/ghq_repos.sh"
        "configuration/gitopolis_repos.sh"
    )

    for script in "${scripts_to_run[@]}"; do
        change_and_run_script "$SCRIPT_DIR/$script"
    done

    echo_with_color "$GREEN_COLOR" "All macOS packages have been installed."
}

install_linux_packages() {
    echo_with_color "$GREEN_COLOR" "Starting package installations for linux..."

    declare -a scripts_to_run=(
        "package-managers/apt.sh"
        "package-managers/pkgx.sh"
        "package-managers/basher.sh"
        "package-managers/krew.sh"
        "package-managers/micro.sh"
        "installers/pyenv_python.sh"
        "package-managers/pip.sh"
        "package-managers/pipx.sh"
        "installers/tfenv_terraform.sh"
        "installers/tailscale.sh"
        "installers/rbenv_ruby.sh"
        "package-managers/gem.sh"
        "installers/rust.sh"
        "package-managers/cargo.sh"
        "installers/fnm_node.sh"
        "package-managers/npm.sh"
        "installers/atuin.sh"
        "installers/ngrok.sh"
        "configuration/go_directories.sh"
        "package-managers/go.sh"
        "installers/nvim.sh"
        "installers/fzf.sh"
        "package-managers/gh_cli.sh"
        "configuration/ghq_repos.sh"
        "configuration/gitopolis_repos.sh"
        "installers/zsh_shell.sh"
        "installers/misc_linux.sh"
    )

    for script in "${scripts_to_run[@]}"; do
        change_and_run_script "$SCRIPT_DIR/$script"
    done

    echo_with_color "$GREEN_COLOR" "All linux packages have been installed."
}

if [[ "$OS" == "MacOS" ]]; then
    install_macos_packages
elif [[ "$OS" == "Linux" ]]; then
    install_linux_packages
else
    echo_with_color "$RED_COLOR" "Unsupported OS: $OS"
    exit 1
fi