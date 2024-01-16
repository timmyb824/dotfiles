#!/Users/timothybryant/.local/bin/bash

#######################
#  Install Python     #
#######################

source "$(dirname "$BASH_SOURCE")/init.sh"

# Pip packages to install
pip_packages=(
    "ansible"
    "gita"
    "pip-autoremove"
    "python-sysinformer"
    "sourcery"
    "spotify_to_ytmusic"
)

# Function to confirm Python version and pip availability
confirm_python_and_pip() {
    local version
    version=$(python -V 2>&1 | awk '{print $2}')
    if [[ "$version" == "${PYTHON_VERSION}" ]]; then
        echo_with_color "32" "Confirmed Python version ${version}."
    else
        exit_with_error "Python version ${version} does not match the desired version ${PYTHON_VERSION}."
    fi

    if command_exists pip; then
        echo_with_color "32" "pip is available."
    else
        exit_with_error "pip is not available."
    fi
}

# Function to install pip packages
install_pip_packages() {
    for package in "${pip_packages[@]}"; do
        if pip install "${package}"; then
            echo_with_color "32" "${package} installed successfully."
        else
            echo_with_color "31" "Failed to install ${package}."
        fi
    done
}

# Install pyenv on Ubuntu if it is not already installed
if ! command_exists pyenv; then
    echo_with_color "32" "pyenv could not be found."
    # Check for curl
    if command_exists curl; then
        echo_with_color "32" "Found curl, attempting to install pyenv and dependencies..."
        # Remove .pyenv if it exists
        rm -rf ~/.pyenv
        sudo apt update
        sudo apt install -y build-essential libssl-dev zlib1g-dev \
            libbz2-dev libreadline-dev libsqlite3-dev curl \
            libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev
        if curl https://pyenv.run | bash; then
            echo_with_color "32" "pyenv installed successfully."

            # Initialize pyenv for the current session
            export PYENV_ROOT="$HOME/.pyenv"
            export PATH="$PYENV_ROOT/bin:$PATH"
            eval "$(pyenv init --path)"
            eval "$(pyenv init -)"

            if pyenv install "${PYTHON_VERSION}"; then
                echo_with_color "32" "Python ${PYTHON_VERSION} installed successfully."

                if pyenv global "${PYTHON_VERSION}"; then
                    echo_with_color "32" "Python ${PYTHON_VERSION} is now in use."
                    confirm_python_and_pip
                else
                    exit_with_error "Failed to set Python ${PYTHON_VERSION} as global, please check pyenv setup."
                fi
            else
                exit_with_error "Failed to install Python ${PYTHON_VERSION}, please check pyenv setup."
            fi
        else
            exit_with_error "Failed to install pyenv, please check curl setup."
        fi
    else
        exit_with_error "curl and pyenv not found. Please install Python to continue."
    fi
else
    echo_with_color "32" "pyenv is already installed and working."
    confirm_python_and_pip
fi

# Prompt user to install pip packages
if ask_yes_or_no "Do you want to install additional pip packages? (ansible, pip-autoremove)"; then
    install_pip_packages
else
    echo_with_color "33" "Skipping pip packages installation."
fi

echo_with_color "32" "python.sh completed successfully."