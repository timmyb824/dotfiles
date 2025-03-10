#!/bin/bash

source common.sh

UV_BASE_DIR="$HOME/uv/virtualenvs"

# Function to create virtualenv
create_venv() {
    local venv_name=$1

    # Create base directories if they don't exist
    mkdir -p "$UV_BASE_DIR"

    # Check if virtualenv already exists
    if [ -d "$UV_BASE_DIR/$venv_name" ]; then
        msg_warn "Virtualenv '$venv_name' already exists in $UV_BASE_DIR"
        exit 1
    fi

    # Create virtualenv
    cd "$UV_BASE_DIR" && uv venv "$venv_name"

    if [ $? -eq 0 ]; then
        msg_ok "Created virtualenv '$venv_name' in $UV_BASE_DIR"
    else
        msg_error "Failed to create virtualenv '$venv_name'"
        exit 1
    fi
}

# Function to activate virtualenv
activate_venv() {
    local venv_name=$1
    local venv_path="$UV_BASE_DIR/$venv_name"

    if [ ! -d "$venv_path" ]; then
        msg_error "Virtualenv '$venv_name' does not exist in $UV_BASE_DIR"
        exit 1
    fi

    msg_info "source $venv_path/bin/activate"
}

# Function to delete virtualenv
delete_venv() {
    local venv_name=$1
    local venv_path="$UV_BASE_DIR/$venv_name"

    if [ ! -d "$venv_path" ]; then
        msg_error "Virtualenv '$venv_name' does not exist in $UV_BASE_DIR"
        exit 1
    fi

    rm -rf "$venv_path"
    msg_ok "Deleted virtualenv '$venv_name'"
}

# Function to cd to virtualenv directory
cd_venv() {
    local venv_name=$1
    local venv_path="$UV_BASE_DIR/$venv_name"

    if [ ! -d "$venv_path" ]; then
        msg_error "Virtualenv '$venv_name' does not exist in $UV_BASE_DIR"
        exit 1
    fi

    msg_info "cd $venv_path"
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
