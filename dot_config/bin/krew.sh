#!/bin/bash

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null
then
    echo "kubectl could not be found"
    exit
fi

# Check if krew is installed
if ! kubectl krew list &> /dev/null
then
    echo "krew could not be found"
    exit
fi

# List of plugins to install
plugins=(
    "ctx"
    "ns"
)

# Iterate over the plugins and install one by one
for plugin in "${plugins[@]}"
do
    if kubectl krew install "${plugin}"; then
        echo "${plugin} installed successfully"
    else
        echo "Failed to install ${plugin}"
    fi
done