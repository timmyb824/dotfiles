#!/bin/bash

# Check if git is installed
if ! command -v git &>/dev/null; then
    echo "git is not installed. Please install git first."
    exit 1
fi

# Check if basher is not already installed
if [ ! -d "$HOME/.basher" ]; then
    echo "basher is not installed. Installing now..."
    if git clone --depth=1 https://github.com/basherpm/basher.git ~/.basher; then
        echo "basher installed successfully"
    else
        echo "basher could not be installed"
        exit 1
    fi
else
    echo "basher is already installed at $HOME/.basher"
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
if [[ ":$PATH:" != *":$basher_bin:"* ]]; then
    # Add basher to PATH
    export PATH="$basher_bin:$PATH"
fi

# Iterate over the packages and install one by one
for package in "${packages[@]}"; do
    if basher install "${package}"; then
        echo "${package} installed successfully"
    else
        echo "Failed to install ${package}"
    fi
done
