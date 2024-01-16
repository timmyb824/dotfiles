#!/usr/bin/env bash

################################################################
#                   Globals                                    #
################################################################

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
OS=$(get_os)

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

################################################################
#     Install chezmoi and run chezmoi init if necessary       #
################################################################

# Function to download and install chezmoi using curl or wget
install_chezmoi() {
    if ! command_exists chezmoi; then
        if command_exists curl; then
            sudo sh -c "$(curl -fsLS get.chezmoi.io)" -- -b /usr/local/bin
        elif command_exists wget; then
            sudo sh -c "$(wget -qO- get.chezmoi.io)" -- -b /usr/local/bin
        else
            exit_with_error "neither curl nor wget is available."
        fi
        return 0
    else
        echo_with_color "32" "chezmoi is already installed."
        return 1
    fi
}


if [ "$OS" = "MacOS" ]; then
    echo_with_color "34" "Detected macOS."
    install_chezmoi

    # Run chezmoi init only if it was just installed
    if [ $? -eq 0 ]; then
        chezmoi init --apply timmyb824
        if [ $? -eq 0 ]; then
            echo_with_color "32" "chezmoi dotfiles have been applied successfully."
        else
            exit_with_error "chezmoi dotfiles could not be applied."
        fi
    fi

elif [ "$OS" = "Linux" ]; then
    echo_with_color "32" "Detected Linux."
    echo_with_color "32" "Skipping chezmoi installation."
fi

# Run install_packages script regardless of the OS or chezmoi installation if the user wants to
if ! ask_yes_or_no "Do you want to continue with package installation?"; then
    echo_with_color "32" "Skipping package installation and ending script."
    exit 0
fi

################################################################
#  Install zsh and set it as the default shell if necessary    #
################################################################

# Check for Zsh and ask to install if not present
if ! command_exists zsh; then
    if ask_yes_or_no "Zsh is not installed. Do you want to install Zsh?"; then
        echo_with_color "33" "Installing Zsh..."
        if [ "$OS" = "Linux" ]; then
            sudo apt-get update
            sudo apt-get install -y zsh
        elif [ "$OS" = "MacOS" ]; then
            # Assuming Homebrew is already installed
            brew install zsh
        else
            exit_with_error "Unknown operating system. Cannot install Zsh."
        fi
    else
        echo_with_color "34" "Skipping Zsh installation."
    fi
else
    echo_with_color "34" "Zsh is already installed."
fi

# Check if the default shell is already Zsh
CURRENT_SHELL=$(getent passwd "$(whoami)" | cut -d: -f7)
if [ "$CURRENT_SHELL" != "$(command -v zsh)" ]; then
    echo "Changing the default shell to Zsh..."
    sudo chsh -s "$(which zsh)" "$(whoami)"
else
    echo_with_color "34" "Zsh is already the default shell."
fi

# Check if we're already running Zsh to prevent a loop
if [ -n "$ZSH_VERSION" ]; then
    echo_with_color "34" "Already running Zsh, no need to switch."
else
    # Executing the Zsh shell
    # The exec command replaces the current shell with zsh.
    # The "$0" refers to the script itself, and "$@" passes all the original arguments passed to the script.
    if [ -x "$(command -v zsh)" ]; then
        echo_with_color "34" "Switching to Zsh for the remainder of the script..."
        exec zsh -l "$0" "$@"
    fi
fi

################################################################
#              Install homebrew packages                       #
################################################################

# Function to install Homebrew on macOS
install_brew_macos() {
    if ! command_exists brew; then
        echo "Homebrew not found. Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        add_brew_to_path
    else
        echo "Homebrew is already installed."
    fi

    if ! command_exists brew; then
        exit_with_error "Homebrew installation failed or PATH setup was not successful."
    fi
}

# Function to optionally install Homebrew on Linux
install_brew_linux() {
    if ask_yes_or_no "Do you want to install Homebrew on Linux?"; then
        echo "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        add_brew_to_path
    else
        echo "Skipping Homebrew installation on Linux."
    fi

    if command_exists brew; then
        echo "Homebrew is installed."
    fi
}

# Prompt the user to install packages using Homebrew
install_packages_with_brew() {
    if ask_yes_or_no "Do you want to install the packages from the Brewfile?"; then
        brew bundle --file=Brewfile
    else
        echo "Skipping package installation."
    fi
}

# Function to update PATH for the current session
add_brew_to_path() {
    # Determine the system architecture for the correct Homebrew path
    local BREW_PREFIX
    if [[ "$(uname -m)" == "arm64" ]]; then
        BREW_PREFIX="/opt/homebrew/bin"
    else
        BREW_PREFIX="/usr/local/bin"
    fi

    # Construct the Homebrew path line
    local BREW_PATH_LINE="eval \"$(${BREW_PREFIX}/brew shellenv)\""

    # Check if Homebrew PATH is already in the PATH
    if ! echo "$PATH" | grep -q "${BREW_PREFIX}"; then
        echo "Adding Homebrew to PATH for the current session..."
        eval "${BREW_PATH_LINE}"
    fi
}

# Main execution
OS=$(get_os)
case $OS in
    "MacOS")
        install_brew_macos
        install_packages_with_brew
        ;;
    "Linux")
        if install_brew_linux; then
            install_packages_with_brew
        fi
        ;;
    *)
        exit_with_error "Unsupported operating system: $OS"
        ;;
esac

echo_with_color "32" "Homebrew installation completed."

################################################################
#           Install tailscale and authenticate                 #
################################################################

# Function to install tailscale on Linux
install_tailscale_linux() {
    echo_with_color "34" "Tailscale is not installed. Would you like to install Tailscale? (y/n)"
    read -r install_confirm
    if [[ "$install_confirm" =~ ^[Yy]$ ]]; then
        echo_with_color "35" "Please enter your Tailscale authorization key:"
        read -r TAILSCALE_AUTH_KEY

        echo_with_color "32" "Installing Tailscale..."

        # Add the Tailscale repository signing key and repository
        curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/jammy.noarmor.gpg | sudo tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null
        curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/jammy.tailscale-keyring.list | sudo tee /etc/apt/sources.list.d/tailscale.list

        # Update the package list and install Tailscale
        sudo apt-get update -y
        sudo apt-get install tailscale -y

        # Start Tailscale and authenticate
        sudo tailscale up --authkey="$TAILSCALE_AUTH_KEY" --operator="$USER"
    else
        echo_with_color "34" "Skipping Tailscale installation."
    fi
}

# Function to install tailscale on macOS
install_tailscale_macos() {
    if mas list | grep -q "Tailscale"; then
        echo_with_color "34" "Tailscale is already installed."
    else
        echo_with_color "35" "Tailscale is not installed. Would you like to install Tailscale? (y/n)"
        read -r install_confirm
        if [[ "$install_confirm" =~ ^[Yy]$ ]]; then
            echo_with_color "35" "Please enter your Tailscale authorization key:"
            read -r TAILSCALE_AUTH_KEY

            echo_with_color "32" "Installing Tailscale..."
            mas install 1475387142
            # Check if Tailscale is successfully installed after the attempt
            if mas list | grep -q "Tailscale"; then
                echo_with_color "32" "Tailscale has been successfully installed."
                # Start Tailscale and authenticate
                sudo tailscale up --authkey="$TAILSCALE_AUTH_KEY" --operator="$USER"
            else
                echo_with_color "31" "Failed to install Tailscale."
            fi
        else
            echo_with_color "31" "Skipping Tailscale installation."
        fi
    fi
}


if [[ "$OS" == "MacOS" ]]; then
    # macOS specific checks
    if ! command_exists mas; then
        echo "mas-cli is not installed. Please install mas-cli to proceed."
        exit 1
    fi
    install_tailscale_macos
elif [[ "$OS" == "Linux" ]]; then
    # Linux specific checks
    if command_exists tailscale; then
        # Check Tailscale status
        status=$(sudo tailscale status)
        if [[ $status == *"Tailscale is stopped."* ]]; then
            echo "Tailscale is installed but stopped. Starting Tailscale..."
            echo "Please enter your Tailscale authorization key:"
            read -r TAILSCALE_AUTH_KEY
            sudo tailscale up --authkey="$TAILSCALE_AUTH_KEY" --operator="$USER"
        else
            echo "Tailscale is running."
        fi
    else
        install_tailscale_linux
    fi
else
    echo "Unsupported operating system."
    exit 1
fi