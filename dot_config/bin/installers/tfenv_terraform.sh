#!/usr/bin/env bash

source_init_script

# Function to install tfenv and Terraform on MacOS
install_tfenv_macos() {
    echo_with_color "$GREEN_COLOR" "Installing tfenv using Homebrew for macOS..."

    if ! command_exists brew; then
        exit_with_error "Homebrew could not be found. Please install Homebrew to continue."
    fi

    brew update
    brew install tfenv

    if ! command_exists tfenv; then
        exit_with_error "tfenv installation failed."
    fi
}

# Function to install and set the desired version of Terraform
install_terraform_version() {
    echo_with_color "$GREEN_COLOR" "Installing Terraform version ${TF_VERSION}..."
    if tfenv install "${TF_VERSION}" && tfenv use "${TF_VERSION}"; then
        installed_version=$(terraform version | head -n 1)
        echo_with_color "$GREEN_COLOR" "Installed Terraform version $installed_version successfully."
    else
        exit_with_error "Failed to install or use Terraform version ${TF_VERSION}. Please check tfenv setup."
    fi
}

# Main script execution
if [[ -z "${TF_VERSION}" ]]; then
    exit_with_error "TF_VERSION is not set. Please set TF_VERSION to the desired Terraform version."
fi

add_brew_to_path

# Check if Terraform is installed and working
if ! command_exists terraform; then
    echo_with_color "$YELLOW_COLOR" "Terraform could not be found."
    install_tfenv_macos
    install_terraform_version
else
    current_version=$(terraform version | head -n 1)
    echo_with_color "$GREEN_COLOR" "Terraform is already installed and working: $current_version"
    # Optionally check if the current version matches TF_VERSION and install if necessary
    if [[ "$(terraform version | head -n 1)" != "Terraform v${TF_VERSION}"* ]]; then
        install_terraform_version
    else
        echo_with_color "$GREEN_COLOR" "Terraform version ${TF_VERSION} is already in use."
    fi
fi