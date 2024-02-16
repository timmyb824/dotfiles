#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../init/init.sh"

# Function to install tfenv and Terraform on MacOS
install_tfenv_macos() {
    echo_with_color "32" "Installing tfenv using Homebrew for macOS..."

    # Check for Homebrew in the common installation locations
    if command_exists brew; then
        echo_with_color "32" "Homebrew is already installed."
    else
        # Attempt to initialize Homebrew if it's installed but not in the PATH
        if [[ -x "/opt/homebrew/bin/brew" ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        else
            # Homebrew is not installed, provide instructions to install it
            echo_with_color "33" "Homebrew is not installed. Please run homebrew.sh first."
            exit_with_error "Homebrew installation required"
        fi
    fi

    brew update
    brew install tfenv

    if ! command_exists tfenv; then
        exit_with_error "tfenv installation failed."
    fi
}

# Main script execution
if [[ "$(get_os)" == "macOS" ]]; then
    if [[ -z "${TF_VERSION}" ]]; then
        exit_with_error "TF_VERSION is not set. Please set TF_VERSION to the desired Terraform version."
    fi

    # Check if Terraform is installed and working
    if ! command_exists terraform; then
        echo_with_color "33" "Terraform could not be found."
        install_tfenv_macos
        echo_with_color "32" "Successfully installed tfenv. Attempting to install Terraform ${TF_VERSION}..."
        if tfenv install "${TF_VERSION}"; then
            installed_version=$(terraform version | head -n 1)
            echo_with_color "32" "Installed Terraform version $installed_version successfully."
            if tfenv use "${TF_VERSION}"; then
                echo_with_color "32" "Terraform ${TF_VERSION} is now in use."
            else
                exit_with_error "Failed to use Terraform ${TF_VERSION}, please check tfenv setup."
            fi
        else
            exit_with_error "Failed to install Terraform ${TF_VERSION}, please check tfenv setup."
        fi
    else
        echo_with_color "32" "Terraform is already installed and working."
    fi
else
    exit_with_error "This script is intended for use on macOS only."
fi