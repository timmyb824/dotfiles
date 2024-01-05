#!/bin/bash

# Check if npm is installed
if ! command -v pipx &> /dev/null
then
    echo "pipx could not be found"
    exit 1
fi

# List of packages to install
packages=(
    "poetry"
    "pyinfra"
)

# Iterate over the packages and install one by one
for package in "${packages[@]}"
do
    if pipx install "${package}"; then
        echo "${package} installed successfully"
    else
        echo "Failed to install ${package}"
    fi
done
