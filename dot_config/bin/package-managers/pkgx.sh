#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../init/init.sh"

# Function to update PATH for the current session
add_brew_to_path() {
    # Determine the system architecture for the correct Homebrew path
    local BREW_PREFIX
    if [[ "$(uname -m)" == "arm64" ]]; then
        BREW_PREFIX="/opt/homebrew/bin"
    else
        BREW_PREFIX="/usr/local/bin"
    fi

    # Check if Homebrew PATH is already in the PATH
    if ! echo "$PATH" | grep -q "${BREW_PREFIX}"; then
        echo_with_color "34" "Adding Homebrew to PATH for the current session..."
        eval "$(${BREW_PREFIX}/brew shellenv)"
    fi
}

# Function to install pkgx
install_pkgx() {
    # Try to add Homebrew to PATH and check again for pkgx
    add_brew_to_path

    # Check if pkgx is available after adding Homebrew to PATH
    if command_exists pkgx; then
        echo_with_color "32" "pkgx is already installed."
    else
        # Attempt to install pkgx with Homebrew
        if command_exists brew; then
            echo_with_color "34" "Installing pkgx using Homebrew..."
            brew install pkgxdev/made/pkgx || exit_with_error "Installation of pkgx using Homebrew failed."
        else
            exit_with_error "Homebrew is not installed. Cannot install pkgx."
        fi
    fi
}

# Check if pkgx is installed, if not then install it
if ! command_exists pkgx; then
    echo_with_color "31" "pkgx could not be found"
    install_pkgx
fi

# Verify if pkgx was successfully installed
command_exists pkgx || exit_with_error "pkgx installation failed."

# Fetch the list of packages to install using get_package_list
packages=( "$(get_package_list pkgx)" )

# Binary paths (edit these as per your system)
mc_bin_path="$HOME/.local/bin/mc"
mcomm_bin_path="$HOME/.local/bin/mcomm"

echo_with_color "34" "Installing packages..."

# Iterate over the packages and install one by one
for package in "${packages[@]}"; do
    # Capture the output of the package installation
    output=$(pkgx install "${package}" 2>&1)

    if [[ "${output}" == *"pkgx: installed:"* ]]; then
        echo_with_color "32" "${package} installed successfully"

        # If the package is mc (Midnight Commander), rename the binary
        if [ "${package}" = "midnight-commander.org" ]; then
            mv "${mc_bin_path}" "${mcomm_bin_path}" || exit_with_error "Failed to rename mc binary to mcomm."
            echo_with_color "32" "Renamed mc binary to mcomm"
        fi
    elif [[ "${output}" == *"pkgx: already installed:"* ]]; then
        echo_with_color "34" "${package} is already installed."
    else
        echo_with_color "31" "Failed to install ${package}: $output"
    fi
done

# Add $HOME/.local/bin to PATH if it's not already there
add_to_path "$HOME/.local/bin"