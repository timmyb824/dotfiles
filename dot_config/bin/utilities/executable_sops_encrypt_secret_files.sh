#!/usr/bin/env bash

source common.sh

# Ensure that AGE_SECRET_KEY is passed as the first argument
if [ -z "$1" ]; then
  echo "Usage: $0 <AGE_SECRET_KEY> <encrypt|decrypt>"
  exit 1
fi
AGE_SECRET_KEY="$1"

# Ensure that the action (encrypt or decrypt) is passed as the second argument
if [ -z "$2" ]; then
  echo "Usage: $0 <AGE_SECRET_KEY> <encrypt|decrypt>"
  exit 1
fi
ACTION="$2"

# Ensure required commands are available
command -v sops >/dev/null 2>&1 || handle_error "sops is required but not installed."
command -v age >/dev/null 2>&1 || handle_error "age is required but not installed."
command -v grep >/dev/null 2>&1 || handle_error "grep is required but not installed."

# Prompt user to confirm they are in the project root
read -p "This script should be run from the project root. Are you in the project root? (y/n) " -n 1 -r
echo # Move to a new line
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  handle_error "Script not run from project root."
fi

# Function to check and encrypt files containing the secret phrase
encrypt_file() {
  local filename="$1"
  # Check for the phrase with various comment styles
  if grep -qE "^(#|--|//)\s*THIS FILE IS A SECRET" "$filename"; then
    log "INFO" "Found secret phrase in file: $filename"
    # Run sops command on the file
    sops --encrypt --age "$AGE_SECRET_KEY" -i "$PWD/$filename"
    if [ $? -ne 0 ]; then
      handle_error "sops encrypt command failed for file: $filename"
    fi
  fi
}

# Function to check and decrypt files containing the encrypted phrase
decrypt_file() {
  local filename="$1"
  # Check for the encrypted phrase
  if grep -q "BEGIN AGE ENCRYPTED FILE" "$filename"; then
    log "INFO" "Found encrypted file: $filename"
    # Run sops command on the file
    sops --decrypt --age "$AGE_SECRET_KEY" -i "$PWD/$filename"
    if [ $? -ne 0 ]; then
      handle_error "sops decrypt command failed for file: $filename"
    fi
  fi
}

# Main processing based on ACTION
if [ "$ACTION" == "encrypt" ]; then
  # Recursively search for files containing the secret phrase and encrypt them
  find . -type f -print0 | while IFS= read -r -d $'\0' file; do
    encrypt_file "$file"
  done
elif [ "$ACTION" == "decrypt" ]; then
  # Recursively search for encrypted files and decrypt them
  find . -type f -print0 | while IFS= read -r -d $'\0' file; do
    decrypt_file "$file"
  done
else
  handle_error "Invalid action: $ACTION. Use 'encrypt' or 'decrypt'."
fi

log "INFO" "Script completed successfully."
