#!/bin/bash

msg_info() {
    echo -e "\033[1;34m[INFO]\033[0m $1"
}

msg_ok() {
    echo -e "\033[1;32m[OK]\033[0m $1"
}

msg_warn() {
    echo -e "\033[1;33m[WARN]\033[0m $1"
}

msg_error() {
    echo -e "\033[1;31m[ERROR]\033[0m $1"
}

logger() {
    echo -e "\033[1;35m$(date +'%Y-%m-%d %H:%M:%S') - $1\033[0m"
    echo -e "---------------------------------------------"
}

handle_error() {
    log "Error: $1"
    exit 1
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

get_os() {
  case "$(uname -s)" in
  Linux*) echo "Linux" ;;
  Darwin*) echo "MacOS" ;;
  *) echo "Unknown" ;;
  esac
}

get_package_list() {
    local package_list_name="$1"
    local gist_url=""

    # Check if the file is Brewfile or ends with .list
    if [[ "$package_list_name" == "Brewfile" ]] || [[ "$package_list_name" == *".list" ]]; then
        gist_url="https://gist.githubusercontent.com/timmyb824/807597f33b14eceeb26e4e6f81d45962/raw/${package_list_name}"
    else
        gist_url="https://gist.githubusercontent.com/timmyb824/807597f33b14eceeb26e4e6f81d45962/raw/${package_list_name}.list"
    fi

    # Fetch the package list, remove comments, and trim whitespace
    curl -fsSL "$gist_url" | sed 's/#.*//' | awk '{$1=$1};1'
}

