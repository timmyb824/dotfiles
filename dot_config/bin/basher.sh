#!/bin/bash

# Check if basher is installed
if ! command -v basher &> /dev/null
then
    echo "basher could not be found"
    exit
fi

# List of packages to install
packages=(
    "LuRsT/hr"
    "bashup/gitea-cli"
    "bltavares/kickstart"
    "dylanaraps/fff"
    "kdabir/has"
    "laurent22/rsync-time-backup"
    "lingtalfi/task-manager"
    "molovo/lumberjack"
    "pforret/bumpkeys"
    "pforret/repeat"
    "pforret/shtext"
    "rauchg/wifi-password"
    "sdushantha/tmpmail"
    "sickill/bitpocket"
    "vaniacer/sshto"
)

# Iterate over the packages and install one by one
for package in "${packages[@]}"
do
    if basher install "${package}"; then
        echo "${package} installed successfully"
    else
        echo "Failed to install ${package}"
    fi
done