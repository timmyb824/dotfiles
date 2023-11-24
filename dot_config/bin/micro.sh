#!/bin/bash

# Check if micro is installed
if ! command -v micro &> /dev/null
then
    echo "micro could not be found"
    exit
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
        echo "${plugin} installed successfully"
    else
        echo "Failed to install ${plugin}"
    fi
done