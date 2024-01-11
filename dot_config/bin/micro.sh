#!/bin/bash

# Source the common functions script
source "$(dirname "$BASH_SOURCE")/init.sh"

# Check if micro is installed
if ! command_exists micro
then
    echo_with_color "31" "micro could not be found"
    exit 1
fi

# List of plugins to install
plugins=(
    "aspell"
    "yapf"
    "bookmark"
    "bounce"
    "filemanager"
    "fish"
    "fzf"
    "go"
    "jump"
    "lsp"
    "manipulator"
    "misspell"
    "nordcolors"
    "quoter"
    "snippets"
    "wc"
    "autoclose"
    "comment"
    "diff"
    "ftoptions"
    "linter"
    "literate"
    "status"
)

# Iterate over the plugins and install one by one
for plugin in "${plugins[@]}"
do
    if micro -plugin install "${plugin}"; then
        echo_with_color "34" "${plugin} installed successfully"
    else
        echo_with_color "31" "Failed to install ${plugin}"
    fi
done

echo_with_color "32" "micro.sh has completed successfully"