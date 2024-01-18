#!/usr/bin/env bash

#######################
#  Install Terraform  #
#######################

source "$(dirname "$BASH_SOURCE")/../utilities/init.sh"

# Check if Terraform is installed and working
if ! command_exists terraform; then
    echo_with_color "33" "Terraform could not be found."

    # Check for tfenv
    if ! command_exists tfenv; then
        echo_with_color "33" "tfenv not found. Installing tfenv..."
        # Clone tfenv into ~/.tfenv
        git clone --depth=1 https://github.com/tfutils/tfenv.git ~/.tfenv
        # Create symlink in a directory that is on the user's PATH
        # Ensure the directory exists and is on PATH
        TFENV_BIN="$HOME/.local/bin"
        mkdir -p "$TFENV_BIN"
        ln -s ~/.tfenv/bin/* "$TFENV_BIN"
        # Add directory to PATH if it's not already there
        add_to_path_exact_match "$TFENV_BIN"
    fi

    # Re-check for tfenv after attempting to install it
    if command_exists tfenv; then
        echo_with_color "32" "Successfully installed tfenv. Attempting to install Terraform ${TF_VERSION}..."
        if tfenv install "${TF_VERSION}"; then
            echo_with_color "32" "Terraform ${TF_VERSION} installed successfully."
            if tfenv use "${TF_VERSION}"; then
                echo_with_color "32" "Terraform ${TF_VERSION} is now in use."
            else
                exit_with_error "Failed to use Terraform ${TF_VERSION}, please check tfenv setup."
            fi
        else
            exit_with_error "Failed to install Terraform ${TF_VERSION}, please check tfenv setup."
        fi
    else
        exit_with_error "Failed to install tfenv. Please check the installation steps."
    fi
else
    echo_with_color "32" "Terraform is already installed and working."
fi