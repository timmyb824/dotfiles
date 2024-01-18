#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../utilities/init.sh"

# Check if git is installed
if ! command_exists git; then
    exit_with_error "git is not installed - please install git and run this script again"
fi

# Check if basher is not already installed
if [ ! -d "$HOME/.basher" ]; then
    echo "basher is not installed. Installing now..."
    if git clone --depth=1 https://github.com/basherpm/basher.git ~/.basher; then
        echo_with_color "32" "basher installed successfully"
    else
        exit_with_error "Failed to install basher"
    fi
else
    echo_with_color "34" "basher is already installed at $HOME/.basher"
fi

# List of packages to install
packages=(
    "LuRsT/hr" # horizontal ruler for terminal
    "bashup/gitea-cli"
    "bltavares/kickstart" # bash only provisioning tool
    "dylanaraps/fff" # file manager
    "kdabir/has" # checks presence of command line tools
    "laurent22/rsync-time-backup"
    "lingtalfi/task-manager"
    "molovo/lumberjack" # log interface for shell scripts
    "pforret/bumpkeys" # ssh-key upgrader
    "pforret/repeat" # repeat a command
    "pforret/shtext" # text manipulation
    "rauchg/wifi-password"
    "sdushantha/tmpmail"
    "sickill/bitpocket" # DIY dropbox
    "vaniacer/sshto"
)

basher_bin="$HOME/.basher/bin"

# Check if basher's bin directory is in the PATH
add_to_path_exact_match "$basher_bin"

# Iterate over the packages and install one by one
for package in "${packages[@]}"; do
    if basher install "${package}"; then
        echo_with_color "32" "${package} installed successfully"
    else
        exit_with_error "Failed to install ${package}"
    fi
done

echo_with_color "32" "basher.sh completed successfully."