#!/bin/bash

# Check if npm is installed
if ! command -v npm &> /dev/null
then
    echo "npm could not be found"
    exit
fi

# List of packages to install
packages=(
    "aicommits"
    "awsp"
    "neovim"
    "opencommit"
    "pm2"
    "kubelive"
    "gtop"
    "lineselect"
)

# Iterate over the packages and install one by one
for package in "${packages[@]}"
do
    if npm install -g "${package}"; then
        echo "${package} installed successfully"
    else
        echo "Failed to install ${package}"
    fi
done
