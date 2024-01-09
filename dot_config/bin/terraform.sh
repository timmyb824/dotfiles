#!/bin/bash

#######################
#  Install terraform  #
#######################

TF_VERSION="latest"

# Check if terraform is installed and working
if ! command -v terraform &>/dev/null; then
    echo_with_color "33" "terraform could not be found"

    # Check for tfenv
    if ! command -v tfenv &>/dev/null; then
        echo_with_color "33" "tfenv not found. Installing tfenv..."
        # Clone tfenv into ~/.tfenv
        git clone --depth=1 https://github.com/tfutils/tfenv.git ~/.tfenv
        # Create symlink in a directory that is on the user's PATH
        # Ensure the directory exists and is on PATH
        TFENV_BIN="$HOME/.local/bin"
        mkdir -p "$TFENV_BIN"
        ln -s ~/.tfenv/bin/* "$TFENV_BIN"
        # Add directory to PATH if it's not already there
        if [[ ":$PATH:" != *":$TFENV_BIN:"* ]]; then
            echo_with_color "33" "Adding $TFENV_BIN to PATH"
            export PATH="$TFENV_BIN:$PATH"
            # Consider adding the PATH update to your shell profile (e.g., ~/.bashrc)
        fi
    fi

    # Re-check for tfenv after attempting to install it
    if command -v tfenv &>/dev/null; then
        echo_with_color "32" "Successfully installed tfenv. Attempting to install terraform ${TF_VERSION}..."
        if tfenv install "${TF_VERSION}"; then
            echo_with_color "32" "terraform ${TF_VERSION} installed successfully"
            if tfenv use "${TF_VERSION}"; then
                echo_with_color "32" "terraform ${TF_VERSION} is now in use"
            else
                echo_with_color "31" "Failed to use terraform ${TF_VERSION}, please check tfenv setup"
                exit 1
            fi
        else
            echo_with_color "31" "Failed to install terraform ${TF_VERSION}, please check tfenv setup"
            exit 1
        fi
    else
        echo_with_color "31" "Failed to install tfenv. Please check the installation steps"
        exit 1
    fi
else
    echo_with_color "32" "terraform is already installed and working."
fi
