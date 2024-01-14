#!/bin/bash

source "$(dirname "$BASH_SOURCE")/init.sh"

########## INSTALLATION STEPS ##########

install_op_cli() {
    # Install the 1Password CLI using the new steps provided
    sudo -s -- <<EOF
curl -sS https://downloads.1password.com/linux/keys/1password.asc | \
gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/$(dpkg --print-architecture) stable main" | \
tee /etc/apt/sources.list.d/1password.list
mkdir -p /etc/debsig/policies/AC2D62742012EA22/
curl -sS https://downloads.1password.com/linux/debian/debsig/1password.pol | \
tee /etc/debsig/policies/AC2D62742012EA22/1password.pol
mkdir -p /usr/share/debsig/keyrings/AC2D62742012EA22
curl -sS https://downloads.1password.com/linux/keys/1password.asc | \
gpg --dearmor --output /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg
apt update && apt install 1password-cli
EOF

    # Check for any errors during the installation process
    if [ $? -ne 0 ]; then
        echo "Error: The 1Password CLI installation failed."
        return 1
    fi

    if ! command_exists op; then
        echo "Error: The 'op' command does not exist after attempting installation."
        return 1
    else
        echo "The 1Password CLI was installed successfully."
    fi
}

# Check if the OS is Linux and install op CLI if it's not already installed
if [ "$(get_os)" = "Linux" ]; then
    if command_exists op; then
        echo "The 1Password CLI is already installed."
    else
        echo "Installing the 1Password CLI..."
        install_op_cli
        INSTALL_SUCCESS=$?
    fi
else
    echo "This script only supports Linux systems."
    exit 1
fi

# Exit if installation failed
if [ "$INSTALL_SUCCESS" -ne 0 ]; then
    echo "Installation failed. Exiting."
    exit 1
fi

########## CONFIGURATION STEPS ##########

read -sp "1Password email: " OP_EMAIL
echo
read -sp "1Passwored Secret Key: " OP_SECRET_KEY
echo
read -sp "1Password Signin Address: " OP_SIGNIN_ADDRESS
echo

# Sign in to your 1Password account to obtain a session token
# The session token is output to STDOUT, so we capture it in a variable
OP_SESSION_TOKEN=$(op account add --address $OP_SIGNIN_ADDRESS --email $OP_EMAIL --secret-key $OP_SECRET_KEY --shorthand personal --signin --raw)
export OP_SESSION_TOKEN

# Check if sign-in was successful
if [[ -z "$OP_SESSION_TOKEN" ]]; then
    echo "Failed to sign in to 1Password CLI."
    exit 1
fi

########## USAGE ##########

# Function to replace template placeholders with secret values from 1Password
process_file() {
    local file_path="$1"
    local destination_dir="$2"
    local file_name=$(basename "$file_path")

    # Ensure destination directory exists
    mkdir -p "$destination_dir"

    while IFS= read -r line; do
        if [[ "$line" == *"onepasswordRead"* ]]; then
            # Extract the 1Password path
            local op_path=$(echo "$line" | grep -oP '{{ onepasswordRead "\K[^"]+')
            if [[ -n "$op_path" ]]; then
                # Fetch the secret from 1Password
                local secret=$(op get item "$op_path" --fields "your_field_name" --session="$OP_SESSION_TOKEN")
                if [[ -n "$secret" ]]; then
                    # Replace the placeholder with the actual secret value
                    line=${line/\{\{ onepasswordRead "op:\/\/Personal\/openai-api\/credential" \}\}/$secret}
                else
                    echo "Error: Unable to retrieve the secret for $op_path"
                    return 1
                fi
            fi
        fi
        echo "$line"
    done < "$file_path" > "$destination_dir/$file_name"
}

# Predefined list of source files and their destinations
declare -A file_map
# file_map["/path/to/source/template1.tpl"]="/path/to/destination1"
file_map["$HOME/dotfiles/dot_aicommits.tmpl"]="$HOME/.aicommits"
# Add more file mappings as needed

# Process each file and copy it to the destination directory
for file_path in "${!file_map[@]}"; do
    destination_dir="${file_map[$file_path]}"
    if [[ -f "$file_path" ]]; then
        echo "Processing $file_path..."
        process_file "$file_path" "$destination_dir"
        if [ $? -eq 0 ]; then
            echo "Processed file $file_path and saved to $destination_dir"
        else
            echo "Failed to process $file_path"
        fi
    else
        echo "File $file_path does not exist."
    fi
done