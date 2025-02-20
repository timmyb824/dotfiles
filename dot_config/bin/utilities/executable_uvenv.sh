#!/bin/bash

UV_BASE_DIR="$HOME/uv/virtualenvs"

# Function to create virtualenv
create_venv() {
    local venv_name=$1

    # Create base directories if they don't exist
    mkdir -p "$UV_BASE_DIR"

    # Check if virtualenv already exists
    if [ -d "$UV_BASE_DIR/$venv_name" ]; then
        echo "Virtualenv '$venv_name' already exists in $UV_BASE_DIR"
        exit 1
    fi

    # Create virtualenv
    cd "$UV_BASE_DIR" && uv venv "$venv_name"

    if [ $? -eq 0 ]; then
        echo "Created virtualenv '$venv_name' in $UV_BASE_DIR"
    else
        echo "Failed to create virtualenv '$venv_name'"
        exit 1
    fi
}

# Function to activate virtualenv
activate_venv() {
    local venv_name=$1
    local venv_path="$UV_BASE_DIR/$venv_name"

    if [ ! -d "$venv_path" ]; then
        echo "Virtualenv '$venv_name' does not exist in $UV_BASE_DIR"
        exit 1
    fi

    echo "source $venv_path/bin/activate"
}

# Function to delete virtualenv
delete_venv() {
    local venv_name=$1
    local venv_path="$UV_BASE_DIR/$venv_name"

    if [ ! -d "$venv_path" ]; then
        echo "Virtualenv '$venv_name' does not exist in $UV_BASE_DIR"
        exit 1
    fi

    rm -rf "$venv_path"
    echo "Deleted virtualenv '$venv_name'"
}

# Function to cd to virtualenv directory
cd_venv() {
    local venv_name=$1
    local venv_path="$UV_BASE_DIR/$venv_name"

    if [ ! -d "$venv_path" ]; then
        echo "Virtualenv '$venv_name' does not exist in $UV_BASE_DIR"
        exit 1
    fi

    echo "cd $venv_path"
}

# Main script logic
if [ $# -eq 0 ]; then
    echo "Usage: $(basename $0) <name>          # Create new virtualenv"
    echo "       $(basename $0) activate <name> # Activate existing virtualenv"
    echo "       $(basename $0) delete <name>   # Delete existing virtualenv"
    echo "       $(basename $0) cd <name>       # Change to virtualenv directory"
    exit 1
fi

case "$1" in
"activate")
    if [ $# -ne 2 ]; then
        echo "Usage: $(basename $0) activate <name>"
        exit 1
    fi
    activate_venv "$2"
    ;;
"delete")
    if [ $# -ne 2 ]; then
        echo "Usage: $(basename $0) delete <name>"
        exit 1
    fi
    delete_venv "$2"
    ;;
"cd")
    if [ $# -ne 2 ]; then
        echo "Usage: $(basename $0) cd <name>"
        exit 1
    fi
    cd_venv "$2"
    ;;
*)
    create_venv "$1"
    ;;
esac
