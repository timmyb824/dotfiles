#!/bin/bash

# Make sure we exit if there is a failure at any step
set -e

# Function to determine the current operating system
get_os() {
  case "$(uname -s)" in
    Linux*)     echo "Linux";;
    Darwin*)    echo "MacOS";;
    *)          echo "Unknown"
  esac
}

# Function to check if a given line is in a file
line_in_file() {
    local line="$1"
    local file="$2"
    grep -Fq -- "$line" "$file"
}

# Check for Zsh and install if not present
if ! command -v zsh &> /dev/null; then
    echo "Zsh not found. Installing Zsh..."

    OS=$(get_os)
    if [ "$OS" = "MacOS" ]; then
        # Install Zsh using Homebrew on macOS
        if ! command -v brew &> /dev/null; then
            echo "Homebrew is required to install Zsh on macOS"
            exit 1
        fi
        brew install zsh
    elif [ "$OS" = "Linux" ]; then
        # Install Zsh using apt-get on Linux
        sudo apt-get update
        sudo apt-get install -y zsh
    else
        echo "Unknown operating system. Cannot install Zsh."
        exit 1
    fi
fi

# Change the default shell to Zsh if it is not already the default
if [ "$(getent passwd "$USER" | cut -d: -f7)" != "$(command -v zsh)" ]; then
    echo "Changing the default shell to Zsh..."
    chsh -s "$(command -v zsh)"
fi

# Homebrew installation and PATH setup
if ! command -v brew &> /dev/null; then
    echo "Homebrew not found. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Check if Homebrew PATH is already in .bashrc
    BREW_PATH_LINE='eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"'
    if ! line_in_file "$BREW_PATH_LINE" ~/.bashrc; then
        echo "Adding Homebrew to PATH in .bashrc..."
        echo "$BREW_PATH_LINE" >> ~/.zshrc
    fi

    # Now source the .bashrc line directly to update the current session
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# Verify if Homebrew was successfully installed
if ! command -v brew &> /dev/null; then
    echo "Error: Homebrew installation failed."
    exit 1
fi

# Install Homebrew dependencies and GCC if on Linux
OS=$(get_os)
if [ "$OS" = "Linux" ]; then
  echo "Installing build-essential and GCC for Linux..."
  sudo apt-get update
  sudo apt-get install -y build-essential
  # Install GCC
  brew install gcc
fi

# Function to make a script executable and run it
run_script() {
    local script=$1
    echo "Running $script..."
    chmod +x "$script"  # Make the script executable
    ./"$script"         # Execute the script
    echo "$script completed."
}

# Start the installation process
echo "Starting package installations..."

echo "Installing packages from Brewfile..."
brew bundle --file=Brewfile

# Run each of the .sh installers
run_script pkgx.sh
run_script basher.sh
run_script krew.sh
run_script micro.sh
run_script npm.sh
run_script pipx.sh

echo "All packages have been installed."
