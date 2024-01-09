#!/bin/bash

# Function to check if a given line is in a file
line_in_file() {
    local line="$1"
    local file="$2"
    grep -Fq -- "$line" "$file"
}

# Function to echo with color and newlines for visibility
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
    echo "Error: $1" >&2
    exit 1
}

# Function to check if a command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Function to add a directory to PATH if it's not already there
add_to_path() {
    if ! echo "$PATH" | grep -q "$1"; then
        echo "Adding $1 to PATH for the current session..."
        export PATH="$1:$PATH"
    fi
}

# Function to safely remove a command using sudo if it exists
safe_remove_command() {
    local cmd_path
    cmd_path=$(command -v "$1") || return 0
    if [[ -n $cmd_path ]]; then
        sudo rm "$cmd_path" && echo "$1 removed successfully." || exit_with_error "Failed to remove $1."
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
                echo "Please answer yes or no."
        esac
    done
}