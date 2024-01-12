#!/bin/bash

#
# Setup common environment variables and configurations
#

# Global variables #

# Get the directory of the current script
SCRIPT_DIR="$(dirname "$(realpath "$BASH_SOURCE")")"
export SCRIPT_DIR

# Global functions #

# Function to check if a given line is in a file
line_in_file() {
    local line="$1"
    local file="$2"
    grep -Fq -- "$line" "$file"
}

# Function to echo with color and newlines for visibility
# 31=red, 32=green, 33=yellow, 34=blue, 35=purple, 36=cyan
echo_with_color() {
    local color_code="$1"
    local message="$2"
    echo -e "\n\033[${color_code}m$message\033[0m\n"
}

# Function to determine the current operating system
get_os() {
    case "$(uname -s)" in
    Linux*) echo "Linux" ;;
    Darwin*) echo "MacOS" ;;
    *) echo "Unknown" ;;
    esac
}

# Function to output an error message and exit
exit_with_error() {
    echo_with_color "31" "Error: $1" >&2
    exit 1
}

# Function to check if a command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Function to add a directory to PATH if it's not already there
add_to_path() {
    if ! echo "$PATH" | grep -q "$1"; then
        echo_with_color "32" "Adding $1 to PATH for the current session..."
        export PATH="$1:$PATH"
    fi
}

# Function to add a directory to PATH if it's not already there and if it's an exact match
add_to_path_exact_match() {
    if [[ ":$PATH:" != *":$1:"* ]]; then
        echo_with_color "32"  "Adding $1 to PATH for the current session..."
        export PATH="$1:$PATH"
    else
        echo_with_color "34"  "$1 is already in PATH"
    fi
}

# Function to safely remove a command using sudo if it exists
safe_remove_command() {
    local cmd_path
    cmd_path=$(command -v "$1") || return 0
    if [[ -n $cmd_path ]]; then
        sudo rm "$cmd_path" && echo_with_color "32" "$1 removed successfully." || exit_with_error "Failed to remove $1."
    fi
}

# Function to ask for yes or no
ask_yes_or_no() {
    while true; do
        read -p "$1 (y/N): " -n 1 -r
        echo
        case "$REPLY" in
            [yY])
                return 0
                ;;
            [nN]|"")
                return 1
                ;;
            *)
                echo_with_color "32"  "Please answer yes or no."
        esac
    done
}

# Function to ask for input
ask_for_input() {
    local prompt="$1"
    local input
    echo_with_color "35" "$prompt"
    read -r input
    echo "$input"
}

# General function to check if a command is available
check_command() {
    local cmd="$1"
    if ! command -v "$cmd" &> /dev/null; then
        echo "$cmd could not be found"
        return 1
    else
        echo "$cmd is available"
        return 0
    fi
}

attempt_fix_command() {
    local cmd="$1"
    local cmd_path="$2"
    if ! check_command "$cmd"; then
        add_to_path "$cmd_path"
        if ! check_command "$cmd"; then
            echo "$cmd is still not available after updating the PATH"
            exit 1
        fi
    fi
}
