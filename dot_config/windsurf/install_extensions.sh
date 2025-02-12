#!/bin/bash

# Check if the argument is provided
if [ -z "$1" ]; then
  echo "Usage: $0 {code|windsurf}"
  exit 1
fi

# Set the argument
ARGUMENT=$1

# Define the path to the extensions file
EXTENSIONS_FILE="$HOME/.config/$ARGUMENT/extensions.txt"

# Check if the extensions file exists
if [ ! -f "$EXTENSIONS_FILE" ]; then
  echo "Extensions file not found: $EXTENSIONS_FILE"
  exit 1
fi

# Install extensions
echo "Installing extensions for $ARGUMENT..."
cat "$EXTENSIONS_FILE" | xargs -n 1 -I {} sh -c '
  if $0 --install-extension {}; then
    echo "Successfully installed: {}"
  else
    echo "Failed to install: {}"
  fi
' $ARGUMENT

echo "Installation process completed."
