#!/usr/bin/env bash

# Unofficial Bash "strict mode"
set -euo pipefail
IFS=$'\t\n' # Stricter IFS settings

usage() {
    cat <<EOF
    Usage: $0 server [script or command] [arguments]

    A script that allows arbitrary shell scripts or commands on the local computer
    to be run on a remote server.

    If a script file is provided, it will be executed on the remote server.
    Otherwise, the command and its arguments will be executed directly.

EOF
}

error_exit() {
    echo "Error: $1"
    usage
    exit 1
}

# Check for SSH client availability
if ! command -v ssh >/dev/null; then
    error_exit "SSH client is not available. Please install it to use this script."
fi

text_color() {
    local color_code="$1"
    shift
    echo -e "\033[${color_code}m$@\033[0m"
}

# Check if we have at least two arguments
if [ $# -lt 2 ]; then
    error_exit "Not enough arguments."
fi

target_server="$1"
shift  # Pop the first argument to access the rest as $@

# Check if the second argument is a file or a command
if [ -f "$1" ]; then
    script_file="$1"
    shift  # Pop the script file to get the arguments
    if [ ! -x "$script_file" ]; then
        error_exit "Script file '$script_file' is not executable or found."
    fi
    # Read the script file content into a variable
    script_content=$(<"$script_file")
else
    # The rest of the arguments are considered part of the command
    script_content="$*"
fi

# Execute the script or command on the remote server
text_color "0;35" "Output from $target_server:"
ssh "$target_server" "bash -s -- $@" <<< "$script_content"