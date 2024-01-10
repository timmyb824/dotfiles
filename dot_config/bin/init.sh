#!/bin/bash

# Define the path to the common.sh script
COMMON_SCRIPT_PATH="$(dirname "$BASH_SOURCE")/common.sh"

# Check if the common script exists and source it
if [ -f "$COMMON_SCRIPT_PATH" ]; then
    source "$COMMON_SCRIPT_PATH"
else
    echo "The common script was not found at $COMMON_SCRIPT_PATH"
    exit 1
fi