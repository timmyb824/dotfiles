#!/bin/bash

#######################
#  Install python     #
#######################

# Set the desired Python version
PYTHON_VERSION="3.11.0"

# Install pyenv on ubuntu if it is not already installed
if ! command -v pyenv &>/dev/null; then
    echo_with_color "32" "pyenv could not be found"

    # Check for curl
    if command -v curl &>/dev/null; then
        echo_with_color "32" "Found curl, attempting to install pyenv and dependencies..."
        # remove .pyenv if it exists
        rm -rf ~/.pyenv
        sudo apt update
        sudo apt install -y build-essential libssl-dev zlib1g-dev \
            libbz2-dev libreadline-dev libsqlite3-dev curl \
            libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev
        if curl https://pyenv.run | bash; then
            echo_with_color "32" "pyenv installed successfully"

            # Initialize pyenv for the current session
            export PYENV_ROOT="$HOME/.pyenv" # homebrew
            export PATH="$PYENV_ROOT/bin:$PATH"
            eval "$(pyenv init --path)"
            eval "$(pyenv init -)"

            if pyenv install "${PYTHON_VERSION}"; then
                echo_with_color "32" "Python ${PYTHON_VERSION} installed successfully"

                if pyenv global "${PYTHON_VERSION}"; then
                    echo_with_color "32" "Python ${PYTHON_VERSION} is now in use"
                else
                    echo_with_color "32" "Failed to use Python ${PYTHON_VERSION}, please check pyenv setup"
                    exit 1
                fi
            else
                echo_with_color "32" "Failed to install Python ${PYTHON_VERSION}, please check pyenv setup"
                exit 1
            fi
        else
            echo_with_color "32" "Failed to install pyenv, please check curl setup"
            exit 1
        fi
    else
        echo_with_color "32" "curl and pyenv not found. Please install Python to continue."
        exit 1
    fi
else
    echo_with_color "32" "pyenv is already installed and working."
fi