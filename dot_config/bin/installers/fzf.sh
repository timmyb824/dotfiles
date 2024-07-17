#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../init/init.sh"

uninstall_fzf_apt() {
    if [ -f /usr/bin/fzf ]; then
        echo_with_color "$YELLOW_COLOR" "fzf is already installed at /usr/bin/fzf"
        echo_with_color "$YELLOW_COLOR" "Uninstalling fzf"
        sudo apt remove fzf -y || exit_with_error "Failed to uninstall fzf"
        echo_with_color "$YELLOW_COLOR" "fzf uninstalled successfully"
    else
        echo_with_color "$YELLOW_COLOR" "fzf is not installed at /usr/bin/fzf"
    fi
}

install_fzf() {
    if git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf; then
        echo_with_color "$GREEN_COLOR" "fzf cloned successfully; running installer"
        if ~/.fzf/install; then
            echo_with_color "$GREEN_COLOR" "fzf installed successfully"
        else
            exit_with_error "Failed to install fzf"
        fi
    else
        exit_with_error "Failed to clone fzf"
    fi
}

clone_fzf_git() {
    if ! command_exists ghq; then
        echo_with_color "$YELLOW_COLOR" "ghq is not installed - attempting to fix"
        add_to_path "$HOME/go/bin"
    fi

    if command_exists ghq; then
        echo_with_color "$GREEN_COLOR" "ghq is installed"
        echo_with_color "$YELLOW_COLOR" "Cloning fzf-git.sh"
        ghq get https://github.com/junegunn/fzf-git.sh || exit_with_error "Failed to clone fzf-git.sh"
    else
        exit_with_error "ghq still not installed - please install it and run script again"
    fi
}

install_fdfind() {
    if ! command_exists fd; then
        if command_exists cargo; then
            echo_with_color "$YELLOW_COLOR" "Installing fd-find"
            cargo install fd-find || exit_with_error "Failed to install fd-find"
        else
            exit_with_error "cargo is not installed - please install cargo and run this script again"
        fi
    else
        echo_with_color "$YELLOW_COLOR" "fd is already installed"
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
    fi
}

# Check if git is installed
if ! command_exists git; then
    exit_with_error "git is not installed - please install git and run this script again"
fi

uninstall_fzf_apt
install_fzf
clone_fzf_git
initialize_cargo
install_fdfind
