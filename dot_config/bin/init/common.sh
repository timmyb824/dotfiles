#!/usr/bin/env bash

############# Global Variables #############

export GREEN_COLOR="32"
export YELLOW_COLOR="33"
export BLUE_COLOR="34"
export RED_COLOR="31"
export CYAN_COLOR="36"

# Store the username of the current user
CURRENT_USER=$(whoami)
export CURRENT_USER

# Array of privileged users
export PRIVILEGED_USERS=("tbryant" "timmyb824" "remoter" "timothybryant" "timothy.bryant")

# Set the desired Node.js version
export NODE_VERSION="21.1.0"

# Set the desired Python version
export PYTHON_VERSION="3.11.0"

# Set the desired Terraform version
export TF_VERSION="latest"

export AGE_RECIPIENT="op://Personal/age-secret-key/username"
export AGE_SECRET_KEY="op://Personal/age-secret-key/credential"
export AGE_SECRET_KEY_FILE="op://Personal/age-secret-key-file/age-master-key.txt"
export AGE_SECRET_KEY_LOCATION="$HOME/.sops/age-master-key.txt"

export CHEZMOI_CONFIG_FILE="op://Personal/chezmoi-toml-config/chezmoi.toml"
export CHEZMOI_CONFIG_FILE_LOCATION="$HOME/.config/chezmoi/chezmoi.toml"

export SOPS_VERSION="v3.8.1"
export AGE_VERSION="v1.1.1"

export RUBY_VERSION="3.2.1"

export ATUIN_USER="tbryant"

export KUBECTL_VERSION="v1.25.0"

export PROMTAIL_VERSION="2.9.8"

export LOKI_URL="https://loki.local.timmybtech.com/loki/api/v1/push"

############# Global functions #############

msg_info() {
    echo -e "\033[1;34m[INFO]\033[0m $1"
}

msg_ok() {
    echo -e "\033[1;32m[OK]\033[0m $1"
}

msg_warn() {
    echo -e "\033[1;33m[WARN]\033[0m $1"
}

msg_error() {
    echo -e "\033[1;31m[ERROR]\033[0m $1"
}

handle_error() {
    msg_error "$1"
    exit 1
}

logger() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" | tee -a "$log_file"
}

# Function to check if the current user is privileged
is_privileged_user() {
    for user in "${PRIVILEGED_USERS[@]}"; do
        if [[ "$CURRENT_USER" == "$user" ]]; then
            return 0 # The user is privileged
        fi
    done
    return 1 # The user is not privileged
}

# source via init.sh
# Function to get a list of packages from a Gist
get_package_list() {
    local package_list_name="$1"
    local gist_url=""

    # Check if the file is Brewfile or ends with .list
    if [[ "$package_list_name" == "Brewfile" ]] || [[ "$package_list_name" == *".list" ]]; then
        gist_url="https://gist.githubusercontent.com/timmyb824/807597f33b14eceeb26e4e6f81d45962/raw/${package_list_name}"
    else
        gist_url="https://gist.githubusercontent.com/timmyb824/807597f33b14eceeb26e4e6f81d45962/raw/${package_list_name}.list"
    fi

    # Fetch the package list, remove comments, and trim whitespace
    curl -fsSL "$gist_url" | sed 's/#.*//' | awk '{$1=$1};1'
}

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
    command -v "$1" &>/dev/null
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
        echo_with_color "32" "Adding $1 to PATH for the current session..."
        export PATH="$1:$PATH"
    else
        echo_with_color "34" "$1 is already in PATH"
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
        [nN] | "")
            return 1
            ;;
        *)
            echo_with_color "32" "Please answer yes or no."
            ;;
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
    if ! command_exists "$cmd"; then
        echo_with_color "31" "$cmd could not be found"
        return 1
    else
        echo_with_color "32" "$cmd is available"
        return 0
    fi
}

attempt_fix_command() {
    local cmd="$1"
    local cmd_path="$2"
    if ! check_command "$cmd"; then
        add_to_path "$cmd_path"
        if ! check_command "$cmd"; then
            exit_with_error "$cmd is still not available after updating the PATH"
        fi
    fi
}

configure_1password_account() {
    if ask_yes_or_no "Would you like to configure 1Password CLI?"; then
        echo_with_color "32" "Configuring 1Password CLI..."

        read -p "1Password email: " OP_EMAIL
        echo
        read -p "1Password Signin Address: " OP_SIGNIN_ADDRESS
        echo
        read -sp "1Password Secret Key: " OP_SECRET_KEY
        echo

        # Attempt to sign in to your 1Password account to obtain a session token
        # The session token is output to STDOUT, so we capture it in a variable
        if OP_SESSION_TOKEN=$(op account add --address "$OP_SIGNIN_ADDRESS" --email "$OP_EMAIL" --secret-key "$OP_SECRET_KEY" --shorthand personal --signin --raw); then
            export OP_SESSION_TOKEN
            echo_with_color "32" "Successfully signed into 1Password CLI."
        else
            echo_with_color "31" "Failed to sign in to 1Password CLI."
            return 1
        fi
    else
        echo_with_color "33" "Skipping 1Password CLI configuration."
    fi
}

1password_sign_in() {
    if eval "$(op signin)"; then
        echo_with_color "32" "Successfully signed into 1Password CLI."
    else
        echo_with_color "31" "Failed to sign in to 1Password CLI."
        return 1
    fi
}

# Function to update PATH for the current session
add_brew_to_path() {
    # Determine the system architecture for the correct Homebrew path
    local BREW_PREFIX
    local BREW_EXECUTABLE
    if [[ "$(uname -m)" == "arm64" ]]; then
        BREW_PREFIX="/opt/homebrew/bin"
    else
        BREW_PREFIX="/usr/local/bin"
    fi
    BREW_EXECUTABLE="${BREW_PREFIX}/brew"

    # Check if Homebrew executable is present
    if [[ -f "$BREW_EXECUTABLE" ]]; then
        # Check if Homebrew PATH is already in the PATH
        if ! echo "$PATH" | grep -q "${BREW_PREFIX}"; then
            echo_with_color "34" "Adding Homebrew to PATH for the current session..."
            export PATH="${BREW_PREFIX}:${PATH}"
        fi
    else
        echo_with_color "33" "Homebrew is not installed at ${BREW_PREFIX}."
    fi
}
